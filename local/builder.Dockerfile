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
    && rm -rf /var/lib/apt/lists/*

# non-root user    
RUN useradd -m devuser && echo "devuser:devuser" | chpasswd && adduser devuser sudo \
    && echo 'devuser ALL=(ALL) NOPASSWD:ALL' > /etc/sudoers.d/devuser \
    && chmod 0440 /etc/sudoers.d/devuser

USER devuser
ENV HOME=/home/devuser
WORKDIR ${HOME}/

# Docker
RUN sudo install -m 0755 -d /etc/apt/keyrings \
    && sudo curl -fsSL https://download.docker.com/linux/debian/gpg -o /etc/apt/keyrings/docker.asc \
    && sudo chmod a+r /etc/apt/keyrings/docker.asc \
    # Add the repository to Apt sources:
    && echo \
    "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.asc] https://download.docker.com/linux/debian bookworm stable" | \
    sudo tee /etc/apt/sources.list.d/docker.list > /dev/null \
    && sudo apt-get update && sudo apt-get install -y \
    # docker-ce \
    docker-ce-cli \
    # containerd.io \
    # docker-buildx-plugin \
    docker-compose-plugin

# GCP CLI
RUN echo "deb [signed-by=/usr/share/keyrings/cloud.google.gpg] https://packages.cloud.google.com/apt cloud-sdk main" | \
    sudo tee -a /etc/apt/sources.list.d/google-cloud-sdk.list \
    && curl https://packages.cloud.google.com/apt/doc/apt-key.gpg | sudo gpg --dearmor -o /usr/share/keyrings/cloud.google.gpg \
    && sudo apt-get update -y && sudo apt-get install google-cloud-sdk -y

# Terraform
ENV TERRAFORM_VERSION=1.7.4
RUN curl -OL https://releases.hashicorp.com/terraform/${TERRAFORM_VERSION}/terraform_${TERRAFORM_VERSION}_linux_amd64.zip \
    && sudo unzip terraform_${TERRAFORM_VERSION}_linux_amd64.zip -d /usr/local/bin/ \
    && rm terraform_${TERRAFORM_VERSION}_linux_amd64.zip

# nvm with node and npm
ENV NVM_DIR=${HOME}/nvm
ENV NODE_VERSION=22.4.0
RUN mkdir $NVM_DIR

RUN curl -o- https://raw.githubusercontent.com/nvm-sh/nvm/v0.34.0/install.sh | bash \
    && . $NVM_DIR/nvm.sh \
    && nvm install $NODE_VERSION \
    && nvm alias default $NODE_VERSION \
    && nvm use default

ENV NODE_PATH=$NVM_DIR/versions/node/v$NODE_VERSION/lib/node_modules
ENV PATH=$NVM_DIR/versions/node/v$NODE_VERSION/bin:$PATH

RUN npm install -g \
    firebase-tools@v13.15.4 \
    npm-check-updates@v17.1.0

# Go
ENV GO_VERSION=1.22.0
RUN curl -OL https://golang.org/dl/go${GO_VERSION}.linux-amd64.tar.gz \
    && sudo tar -C /usr/local -xzf go${GO_VERSION}.linux-amd64.tar.gz \
    && rm go${GO_VERSION}.linux-amd64.tar.gz
ENV CGO_ENABLED=1
ENV PATH=${PATH}:/usr/local/go/bin:${HOME}/go/bin

# Android SDK
RUN sudo apt-get update && sudo apt-get install -y curl unzip default-jdk
ENV ANDROID_SDK=${HOME}/Android/Sdk
ENV PATH=$PATH:$ANDROID_SDK/cmdline-tools/latest/bin
RUN mkdir -p $ANDROID_SDK/cmdline-tools/ \
    && cd $ANDROID_SDK/cmdline-tools/ \
    && curl -o sdk.zip -L https://dl.google.com/android/repository/commandlinetools-linux-11076708_latest.zip \
    && unzip sdk.zip && rm sdk.zip \
    && mv cmdline-tools latest \
    && yes | sdkmanager --licenses \
    && sdkmanager "platform-tools" "platforms;android-30"

ENV ANDROID_HOME=$HOME/Library/Android/sdk
ENV PATH=$PATH:$ANDROID_HOME/emulator
ENV PATH=$PATH:$ANDROID_HOME/tools
ENV PATH=$PATH:$ANDROID_HOME/tools/bin
ENV PATH=$PATH:$ANDROID_HOME/platform-tools
# Flutter 
ENV FLUTTER_VERSION=3.24.3
RUN sudo apt-get update && sudo apt-get install -y \
    clang cmake ninja-build libgtk-3-dev
RUN curl -o flutter.tar.xz -L https://storage.googleapis.com/flutter_infra_release/releases/stable/linux/flutter_linux_${FLUTTER_VERSION}-stable.tar.xz && \
    tar -xf flutter.tar.xz -C ${HOME}/ && rm flutter.tar.xz
ENV PATH=${PATH}:${HOME}/flutter/bin

RUN if [ "`dpkg --print-architecture`" = "amd64" ] && [ "`uname`" = "Linux" ]; then \
    sdkmanager "build-tools;30.0.1" && \
    # Telemetry is not sent on the very first run. To disable reporting of telemetry,
    # run this terminal command:
    flutter --disable-analytics && \
    # Accept All Androïd SDK package licenses
    flutter doctor --android-licenses ; \
    fi

# Install necessary software packages for having an X
RUN sudo apt-get update && sudo apt-get install -y \
    x11vnc \
    xvfb \
    xinit openbox xorg

# Installer Google Chrome
RUN if [ "`dpkg --print-architecture`" = "amd64" ] && [ "`uname`" = "Linux" ]; then \
    curl -OL https://dl.google.com/linux/direct/google-chrome-stable_current_amd64.deb && \
    sudo dpkg -i google-chrome-stable_current_amd64.deb ; \
    sudo apt-get install -f -y ; \
    else \
    echo TARGETPLATFORM =  `dpkg --print-architecture && uname` ; sleep 10;\
    echo "Chrome not supported on this platform "  ; \
    echo "Installing chromium"; \
    sudo apt-get install -y chromium; \
    fi

# X11
COPY local/display-start.sh /usr/local/bin/

# The workspace folder value '/workspaces/<project>' is enforced by Github Codespaces (see .devcontainer/devcontainer.json).
# It must be a static value due to limitations in the Devcontainer as it doesn't support variables and treats any syntax as a hard value without expansion.
# Luckily this restriction only applies to Github Codespaces. If another platform imposed the same restriction, we would face a complicated decision.
# Refer to https://containers.dev for more about the containers.dev initiative.

# To address this, we mimic the same workspace folder across different environments using a symlink hardcoded to '/workspaces/<project>'.
# This approach is beneficial when your environment needs to mount the current workspace in third-party containers, such as running a development docker-compose.

# Requiring alignment between the container mounted workspace folder path inside the container and outside,
# enables transparent work on the project files inside and outside of the development container, which can be destroyed and recreated with minimal impact and restart time.

# It further allows cache redirection inside the current folder located on docker daemon host physical disks (see .devcontainer/post-create-cmd.sh).
# It is superior to volumes as generated files stay within the local checked-out project folder, eliminating docker volume management and enabling access to locally readable container cache outside docker.

# When /var/run/docker.sock is mounted by docker daemon inside a running container (see docker-compose.yml) the host's docker is used.
# If you run the command 'docker run -v`pwd`:`pwd` -w `pwd` sh' it will display the current folder inside the container at the same virtual position where it currently resides, an existing path on the daemon underlying file system.

# Using this technique, you can safely mount files under your project path inside new containers like third party development containers with a local docker-compose.yml for local functional tests for instance.
ARG host_pwd
RUN if [ "${host_pwd}" != "/workspaces/refactored-winner" ]; then \
    sudo mkdir -p /workspaces && \
    sudo ln -s ${host_pwd} /workspaces/refactored-winner ; \
    fi

RUN sudo ln -sf /usr/bin/bash /bin/sh

ENV DISPLAY=":1"

COPY local/dev-entrypoint.sh /usr/local/bin/