FROM docker:dind-rootless AS docker

FROM debian:bookworm

RUN apt-get update && apt-get install -y \
    apt-transport-https \
    bash-completion \
    build-essential \
    ca-certificates \
    curl \
    dnsutils \
    file \
    g++ \
    gcc \
    git \
    gnupg \
    htop \
    iptables \
    iftop \
    jq \
    libbz2-1.0 \
    libc6 \
    libcairo2-dev \
    libgif-dev \
    libglu1-mesa \
    libjpeg-dev \
    libncurses5\
    libpango1.0-dev \
    librsvg2-dev \
    libstdc++6 \
    lsb-release \
    lsof \
    make \
    net-tools \
    netcat-openbsd \
    openjdk-17-jdk \
    procps \
    socat \
    sudo \
    unzip \
    vim \
    xz-utils \
    zip \
    # X
    x11vnc \
    xvfb \
    xinit openbox xorg \
    #Flutter
    clang \
    cmake \
    ninja-build \
    libgtk-3-dev \
    # google-chrome-stable required:
    fonts-liberation \
    libvulkan1 \
    wget \
    xdg-utils \
    && rm -rf /var/lib/apt/lists/*

# GCP CLI
RUN echo "deb [signed-by=/usr/share/keyrings/cloud.google.gpg] https://packages.cloud.google.com/apt cloud-sdk main" | \
    tee -a /etc/apt/sources.list.d/google-cloud-sdk.list \
    && curl https://packages.cloud.google.com/apt/doc/apt-key.gpg | gpg --dearmor -o /usr/share/keyrings/cloud.google.gpg \
    && apt-get update -y && apt-get install google-cloud-sdk -y

# Terraform
ENV TERRAFORM_VERSION=1.9.7
RUN curl -OL https://releases.hashicorp.com/terraform/${TERRAFORM_VERSION}/terraform_${TERRAFORM_VERSION}_linux_amd64.zip \
    && unzip terraform_${TERRAFORM_VERSION}_linux_amd64.zip -d /usr/local/bin/ \
    && rm terraform_${TERRAFORM_VERSION}_linux_amd64.zip

ARG non_root_user=devuser

# Add non-root user    
RUN useradd -m ${non_root_user} -u 1000 && echo "${non_root_user}:${non_root_user}" | chpasswd && adduser ${non_root_user} sudo \
    && echo "${non_root_user} ALL=(ALL) NOPASSWD:ALL" > /etc/sudoers.d/${non_root_user} \
    && chmod 0440 /etc/sudoers.d/${non_root_user}

USER ${non_root_user}
ENV HOME=/home/${non_root_user}
WORKDIR ${HOME}/

# nvm with node and npm
ENV NVM_DIR=${HOME}/nvm
ENV NVM_VERSION=v0.40.1
ENV NPM_VERSION=10.9.0
ENV NODE_VERSION=22.9.0
RUN mkdir $NVM_DIR

RUN curl -o- https://raw.githubusercontent.com/nvm-sh/nvm/${NVM_VERSION}/install.sh | bash \
    && . $NVM_DIR/nvm.sh \
    && nvm install $NODE_VERSION \
    && nvm alias default $NODE_VERSION \
    && nvm use default

ENV NODE_PATH=$NVM_DIR/versions/node/v$NODE_VERSION/lib/node_modules
ENV PATH=$NVM_DIR/versions/node/v$NODE_VERSION/bin:$PATH

RUN npm install -g \
    firebase-tools \
    depcheck \
    npm-check-updates \
    npm-check \
    npm \
    && rm -rf ${HOME}/.npm

# Go
ENV GO_VERSION=1.23.4
ARG TARGETPLATFORM

USER root
RUN case "$TARGETPLATFORM" in \
    "linux/amd64") \
    LATEST_GOLANG=$(curl -s https://go.dev/dl/ | grep -oP '(go.*?.linux-amd64.tar.gz)' | head -1) ; \
    ;; \
    "linux/arm64") \
    LATEST_GOLANG=$(curl -s https://go.dev/dl/ | grep -oP '(go.*?.linux-arm64.tar.gz)' | head -1) ; \
    ;; \
    esac \
    && curl -o- https://dl.google.com/go/${LATEST_GOLANG} | tar xz -C /usr/local --

ENV CGO_ENABLED=1
ENV PATH=${PATH}:/usr/local/go/bin:${HOME}/go/bin

COPY local/proxy ${HOME}/localproxy
RUN cd ${HOME}/localproxy \
    && GOCACHE=/tmp/gocache \
    && GOPATH=/tmp/go \
    go install -v \
    && cp /tmp/go/bin/proxy /usr/local/bin/localproxy 

# Android SDK
ENV ANDROID_SDK=${HOME}/Android/Sdk
ENV PATH=$PATH:$ANDROID_SDK/cmdline-tools/latest/bin
ENV PATH=$PATH:$ANDROID_SDK/emulator:$ANDROID_SDK/tools:$ANDROID_SDK/tools/bin:$ANDROID_SDK/platform-tools

USER ${non_root_user}

# RUN ANDROID_COMMANDLINETOOLS_URL=$(curl -s https://developer.android.com/studio \
#     | grep -oP '(https://dl.google.com/android/repository/commandlinetools-linux-.*?_latest.zip)' | head -1); \
RUN ANDROID_COMMANDLINETOOLS_URL=https://dl.google.com/android/repository/commandlinetools-linux-11076708_latest.zip; \
    mkdir -p $ANDROID_SDK/cmdline-tools/ && \
    cd $ANDROID_SDK/cmdline-tools/ && \
    curl -o sdk.zip -L $ANDROID_COMMANDLINETOOLS_URL && \
    unzip sdk.zip && \
    rm sdk.zip && \
    mv cmdline-tools latest && \
    yes | sdkmanager --licenses && \
    sdkmanager "platform-tools" "platforms;android-30"

ENV STUDIO_PATH=${HOME}/android-studio
ENV PATH=${STUDIO_PATH}/bin:${PATH}

ARG android_studio_version=2024.2.1.11
# RUN ANDROID_STUDIO_URL=$(curl -s https://developer.android.com/studio \
# | grep -oP '(https://redirector.gvt1.com/edgedl/android/studio/ide-zips/.*?linux.tar.gz)' | head -1); \
RUN ANDROID_STUDIO_URL=https://redirector.gvt1.com/edgedl/android/studio/ide-zips/${android_studio_version}/android-studio-${android_studio_version}-linux.tar.gz ; \
    curl -o /tmp/android-studio.tar.gz -L ${ANDROID_STUDIO_URL}  && \
    tar -xzf /tmp/android-studio.tar.gz -C /tmp/ && \
    mv /tmp/android-studio ${STUDIO_PATH} && \
    rm /tmp/android-studio.tar.gz

USER root
COPY local/android/caches-refresh.sh /usr/local/bin/local-android-caches-refresh.sh

# Install Google Chrome
RUN if [ "`dpkg --print-architecture`" = "amd64" ] && [ "`uname`" = "Linux" ]; then \
    curl -OL https://dl.google.com/linux/direct/google-chrome-stable_current_amd64.deb && \
    dpkg -i google-chrome-stable_current_amd64.deb && \
    apt-get install -f -y ; \
    else \
    echo TARGETPLATFORM =  `dpkg --print-architecture` ; \
    echo "Chrome not supported on this platform "  ; \
    echo "Installing chromium"; \
    apt-get update && apt-get install -y chromium; \
    fi

# X11
COPY local/display-start.sh /usr/local/bin/
ENV DISPLAY=":1"

# Use Bash
RUN ln -sf /usr/bin/bash /bin/sh
RUN chown -R ${non_root_user}:${non_root_user} ${HOME}/.config
RUN chown -R ${non_root_user}:${non_root_user} ${HOME}/.cache
USER ${non_root_user}

# Flutter 
ENV FLUTTER_VERSION=3.27.1
RUN curl -o flutter.tar.xz -L https://storage.googleapis.com/flutter_infra_release/releases/stable/linux/flutter_linux_${FLUTTER_VERSION}-stable.tar.xz && \
    tar -xf flutter.tar.xz -C ${HOME}/ && rm flutter.tar.xz
ENV PATH=${PATH}:${HOME}/flutter/bin

RUN if [ "`dpkg --print-architecture`" = "amd64" ] && [ "`uname`" = "Linux" ]; then \
    sdkmanager "build-tools;30.0.1" "build-tools;35.0.0" && \
    # Telemetry is not sent on the very first run. To disable reporting of telemetry,
    # run this terminal command:
    flutter --disable-analytics && \
    # Accept All Androïd SDK package licenses
    flutter doctor --android-licenses ; \
    fi

RUN curl --proto '=https' --tlsv1.2 -sSf https://raw.githubusercontent.com/nektos/act/master/install.sh | sudo bash

COPY --from=docker /usr/local/bin/dockerd-entrypoint.sh /usr/local/bin/
COPY --from=docker /usr/local/bin/docker-entrypoint.sh /usr/local/bin/
COPY --from=docker /usr/local/bin/modprobe /usr/local/bin/

COPY local/dev-entrypoint.sh /usr/local/bin/

USER root

RUN mkdir -p /run/user && chmod 1777 /run/user

ENV DOCKER_VERSION 27.4.0

RUN set -eux; \
    \
    case "$TARGETPLATFORM" in \
    "linux/amd64") \
    url='https://download.docker.com/linux/static/stable/x86_64/docker-27.4.0.tgz'; \
    ;; \
    "linux/arm64") \
    url='https://download.docker.com/linux/static/stable/aarch64/docker-27.4.0.tgz'; \
    ;; \
    *) echo >&2 "error: unsupported 'docker.tgz' architecture ($TARGETPLATFORM)"; exit 1 ;; \
    esac; \
    \
    wget -O 'docker.tgz' "$url"; \
    \
    tar --extract \
    --file docker.tgz \
    --strip-components 1 \
    --directory /usr/local/bin/ \
    --no-same-owner \
    'docker/containerd' \
    'docker/docker' \
    'docker/dockerd' \
    'docker/runc' \
    'docker/containerd-shim-runc-v2' \
    'docker/ctr' \
    'docker/docker-proxy' \
    'docker/docker-init' \
    ; \
    rm docker.tgz; \
    \
    docker --version

RUN set -eux; \
    \
    case "$TARGETPLATFORM" in \
    "linux/amd64") \
    url='https://download.docker.com/linux/static/test/x86_64/docker-rootless-extras-27.4.0-rc.4.tgz'; \
    ;; \
    "linux/arm64") \
    url='https://download.docker.com/linux/static/test/aarch64/docker-rootless-extras-27.4.0-rc.4.tgz'; \
    ;; \
    *) echo >&2 "error: unsupported 'rootless.tgz' architecture ($TARGETPLATFORM)"; exit 1 ;; \
    esac; \
    \
    wget -O 'rootless.tgz' "${url}"; \
    \
    tar --extract \
    --file rootless.tgz \
    --strip-components 1 \
    --directory /usr/local/bin/ \
    'docker-rootless-extras/rootlesskit' \
    'docker-rootless-extras/rootlesskit-docker-proxy' \
    'docker-rootless-extras/vpnkit' \
    ; \
    rm rootless.tgz; \
    \
    rootlesskit --version; \
    vpnkit --version

USER devuser

# pre-create "/var/lib/docker" for our rootless user
RUN set -eux; \
    mkdir -p /home/devuser/.local/share/docker; \
    chown -R devuser:devuser /home/devuser/.local/share/docker
VOLUME /home/devuser/.local/share/docker

USER root

ENV DOCKER_BUILDX_VERSION 0.19.2
RUN set -eux; \
    \
    case "$TARGETPLATFORM" in \
    "linux/amd64") \
    url='https://github.com/docker/buildx/releases/download/v0.19.2/buildx-v0.19.2.linux-amd64'; \
    sha256='a5ff61c0b6d2c8ee20964a9d6dac7a7a6383c4a4a0ee8d354e983917578306ea'; \
    ;; \
    "linux/arm64") \
    url='https://github.com/docker/buildx/releases/download/v0.19.2/buildx-v0.19.2.linux-arm64'; \
    sha256='bd54f0e28c29789da1679bad2dd94c1923786ccd2cd80dd3a0a1d560a6baf10c'; \
    ;; \
    *) echo >&2 "warning: unsupported 'docker-buildx' architecture ($TARGETPLATFORM); skipping"; exit 0 ;; \
    esac; \
    \
    wget -O 'docker-buildx' "$url"; \
    echo "$sha256 *"'docker-buildx' | sha256sum -c -; \
    \
    plugin='/usr/local/libexec/docker/cli-plugins/docker-buildx'; \
    mkdir -p "$(dirname "$plugin")"; \
    mv -vT 'docker-buildx' "$plugin"; \
    chmod +x "$plugin"; \
    \
    docker buildx version ; \
    #
    # ENV DOCKER_COMPOSE_VERSION 2.31.0
    # RUN set -eux; \
    \
    case "$TARGETPLATFORM" in \
    "linux/amd64") \
    url='https://github.com/docker/compose/releases/download/v2.31.0/docker-compose-linux-x86_64'; \
    sha256='8b5d2cb358427e654ada217cfdfedc00c4273f7a8ee07f27003a18d15461b6cd'; \
    ;; \
    "linux/arm64") \
    url='https://github.com/docker/compose/releases/download/v2.31.0/docker-compose-linux-aarch64'; \
    sha256='a1f85584584d0c3c489f31f015c97eb543f1f0949fdc5ce3ded88c05a5188729'; \
    ;; \
    *) echo >&2 "warning: unsupported 'docker-compose' architecture ($TARGETPLATFORM); skipping"; exit 0 ;; \
    esac; \
    \
    wget -O 'docker-compose' "$url"; \
    echo "$sha256 *"'docker-compose' | sha256sum -c -; \
    \
    plugin='/usr/local/libexec/docker/cli-plugins/docker-compose'; \
    mkdir -p "$(dirname "$plugin")"; \
    mv -vT 'docker-compose' "$plugin"; \
    chmod +x "$plugin"; \
    \
    ln -sv "$plugin" /usr/local/bin/; \
    docker-compose --version; \
    docker compose version

RUN apt-get update && apt-get install -y uidmap iproute2 iptables

# note: you can change the v2.12.0 with version that are available in the releases page.
RUN wget -nv https://github.com/hirosystems/clarinet/releases/download/v2.12.0/clarinet-linux-x64-glibc.tar.gz -O clarinet-linux-x64.tar.gz && \
    tar -xf clarinet-linux-x64.tar.gz && \
    chmod +x ./clarinet && \
    mv ./clarinet /usr/local/bin && \
    clarinet completion bash && \
    mv clarinet.bash /etc/bash_completion.d/clarinet.bash && \
    echo 'source /etc/bash_completion.d/clarinet.bash' >> ~/.bashrc

USER devuser
