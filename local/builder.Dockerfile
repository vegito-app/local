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


# Docker
RUN install -m 0755 -d /etc/apt/keyrings \
    && curl -fsSL https://download.docker.com/linux/debian/gpg -o /etc/apt/keyrings/docker.asc \
    && chmod a+r /etc/apt/keyrings/docker.asc \
    # Add the repository to Apt sources:
    && echo \
    "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.asc] https://download.docker.com/linux/debian bookworm stable" \
    > /etc/apt/sources.list.d/docker.list \
    && apt-get update && apt-get install -y \
    # docker-ce \
    docker-ce-cli \
    # containerd.io \
    # docker-buildx-plugin \
    docker-compose-plugin

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
ENV GO_VERSION=1.23.2
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
    && GOPATH=/tmp/go \
    go install -v \
    && cp /tmp/go/bin/proxy /usr/local/bin/localproxy 

USER ${non_root_user}

# Android SDK
ENV ANDROID_SDK=${HOME}/Android/Sdk
ENV PATH=$PATH:$ANDROID_SDK/cmdline-tools/latest/bin
ENV PATH=$PATH:$ANDROID_SDK/emulator:$ANDROID_SDK/tools:$ANDROID_SDK/tools/bin:$ANDROID_SDK/platform-tools

RUN LATEST_ANDROID_COMMANDLINETOOLS_URL=$(curl -s https://developer.android.com/studio | grep -oP '(https://dl.google.com/android/repository/commandlinetools-linux-.*?_latest.zip)' | head -1); \
    mkdir -p $ANDROID_SDK/cmdline-tools/ && \
    cd $ANDROID_SDK/cmdline-tools/ && \
    curl -o sdk.zip -L $LATEST_ANDROID_COMMANDLINETOOLS_URL && \
    unzip sdk.zip && \
    rm sdk.zip && \
    mv cmdline-tools latest && \
    yes | sdkmanager --licenses && \
    sdkmanager "platform-tools" "platforms;android-30"

# Set environment variables for Android Studio
ENV STUDIO_URL=https://redirector.gvt1.com/edgedl/android/studio/ide-zips/2024.1.1.12/android-studio-2024.1.1.12-linux.tar.gz
ENV STUDIO_PATH=${HOME}/android-studio
ENV PATH=${STUDIO_PATH}/bin:${PATH}

# Download and unarchive latest Android Studio
RUN LATEST_STUDIO_URL=$(curl -s https://developer.android.com/studio | grep -oP '(https://redirector.gvt1.com/edgedl/android/studio/ide-zips/.*?linux.tar.gz)' | head -1); \
    curl -o /tmp/android-studio.tar.gz -L ${LATEST_STUDIO_URL}  && \
    tar -xzf /tmp/android-studio.tar.gz -C /tmp/ && \
    mv /tmp/android-studio ${STUDIO_PATH} && \
    rm /tmp/android-studio.tar.gz

COPY local/android/caches-refresh.sh /usr/local/bin/local-android-caches-refresh.sh

USER root

# Install Google Chrome
RUN if [ "`dpkg --print-architecture`" = "amd64" ] && [ "`uname`" = "Linux" ]; then \
    curl -OL https://dl.google.com/linux/direct/google-chrome-stable_current_amd64.deb && \
    dpkg -i google-chrome-stable_current_amd64.deb && \
    apt-get install -f -y ; \
    else \
    echo TARGETPLATFORM =  `dpkg --print-architecture && uname` ; sleep 10;\
    echo "Chrome not supported on this platform "  ; \
    echo "Installing chromium"; \
    apt-get install -y chromium; \
    fi

# X11
COPY local/display-start.sh /usr/local/bin/
ENV DISPLAY=":1"

RUN chown -R ${non_root_user}:${non_root_user} ${HOME}

# Use Bash
RUN ln -sf /usr/bin/bash /bin/sh

USER ${non_root_user}

# Flutter 
ENV FLUTTER_VERSION=3.24.3
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

COPY local/dev-entrypoint.sh /usr/local/bin/