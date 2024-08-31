FROM debian:bookworm

# Updating packages and installing dependencies
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
    libbz2-1.0:amd64 \
    libc6:amd64 \
    libcairo2-dev \
    libgif-dev \
    libglu1-mesa \
    libjpeg-dev \
    libncurses5:amd64\
    libpango1.0-dev \
    librsvg2-dev \
    libstdc++6:amd64 \
    lsb-release \
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

# Installing Go
ENV GO_VERSION=1.22.0
RUN curl -OL https://golang.org/dl/go${GO_VERSION}.linux-amd64.tar.gz \
    && tar -C /usr/local -xzf go${GO_VERSION}.linux-amd64.tar.gz \
    && rm go${GO_VERSION}.linux-amd64.tar.gz
ENV CGO_ENABLED=1

# Install Docker
RUN install -m 0755 -d /etc/apt/keyrings \
    && curl -fsSL https://download.docker.com/linux/debian/gpg -o /etc/apt/keyrings/docker.asc \
    && chmod a+r /etc/apt/keyrings/docker.asc \
    # Add the repository to Apt sources:
    && echo \
    "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.asc] https://download.docker.com/linux/debian bookworm stable" | \
    tee /etc/apt/sources.list.d/docker.list > /dev/null \
    && apt-get update && apt-get install -y \
    # docker-ce \
    docker-ce-cli \
    # containerd.io \
    # docker-buildx-plugin \
    docker-compose-plugin

# Installing GCP CLI
RUN echo "deb [signed-by=/usr/share/keyrings/cloud.google.gpg] https://packages.cloud.google.com/apt cloud-sdk main" | tee -a /etc/apt/sources.list.d/google-cloud-sdk.list \
    && curl https://packages.cloud.google.com/apt/doc/apt-key.gpg | gpg --dearmor -o /usr/share/keyrings/cloud.google.gpg \
    && apt-get update -y && apt-get install google-cloud-sdk -y

# Installing Terraform
ENV TERRAFORM_VERSION=1.7.4
RUN curl -OL https://releases.hashicorp.com/terraform/${TERRAFORM_VERSION}/terraform_${TERRAFORM_VERSION}_linux_amd64.zip \
    && unzip terraform_${TERRAFORM_VERSION}_linux_amd64.zip -d /usr/local/bin/ \
    && rm terraform_${TERRAFORM_VERSION}_linux_amd64.zip

# Install nvm with node and npm
ENV NVM_DIR /usr/local/nvm
ENV NODE_VERSION 22.4.0

RUN mkdir $NVM_DIR

RUN curl -o- https://raw.githubusercontent.com/nvm-sh/nvm/v0.34.0/install.sh | bash \
    && . $NVM_DIR/nvm.sh \
    && nvm install $NODE_VERSION \
    && nvm alias default $NODE_VERSION \
    && nvm use default

ENV NODE_PATH $NVM_DIR/versions/node/v$NODE_VERSION/lib/node_modules
ENV PATH      $NVM_DIR/versions/node/v$NODE_VERSION/bin:$PATH

RUN npm install -g \
    firebase-tools@v13.15.4 \
    npm-check-updates@v17.1.0

# non-root user    
RUN useradd -m devuser && echo "devuser:devuser" | chpasswd && adduser devuser sudo \
    && echo 'devuser ALL=(ALL) NOPASSWD:ALL' > /etc/sudoers.d/devuser \
    && chmod 0440 /etc/sudoers.d/devuser

USER devuser
ENV HOME=/home/devuser
WORKDIR ${HOME}/
ENV PATH=${PATH}:/usr/local/go/bin:${HOME}/go/bin

# Check node and npm versions
RUN node -v && npm -v

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

RUN  curl -OL https://storage.googleapis.com/flutter_infra_release/releases/stable/linux/flutter_linux_3.24.1-stable.tar.xz && \
    tar -xf flutter_linux_3.24.1-stable.tar.xz -C ${HOME}

ENV PATH=${PATH}:${HOME}/flutter/bin

COPY dev-entrypoint.sh /usr/local/bin/
