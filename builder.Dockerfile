FROM debian:bookworm

# Updating packages and installing dependencies
RUN apt-get update && apt-get install -y \
    apt-transport-https \
    bash-completion \
    ca-certificates \
    curl \
    gcc \
    g++ \
    git \
    gnupg \
    htop \
    jq \
    lsb-release \
    make \
    procps \
    sudo \
    unzip \
    build-essential \
    libcairo2-dev \
    libpango1.0-dev \
    libjpeg-dev \
    libgif-dev \
    librsvg2-dev \
    vim \
    && rm -rf /var/lib/apt/lists/*

# Installing Go
ENV GO_VERSION=1.22.0
RUN curl -OL https://golang.org/dl/go${GO_VERSION}.linux-amd64.tar.gz \
    && tar -C /usr/local -xzf go${GO_VERSION}.linux-amd64.tar.gz \
    && rm go${GO_VERSION}.linux-amd64.tar.gz
ENV PATH=$PATH:/usr/local/go/bin
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

RUN curl -fsSL https://deb.nodesource.com/setup_22.x | bash - && \
    apt-get install -y nodejs

# non-root user    
RUN useradd -m devuser && echo "devuser:devuser" | chpasswd && adduser devuser sudo \
    && echo 'devuser ALL=(ALL) NOPASSWD:ALL' > /etc/sudoers.d/devuser \
    && chmod 0440 /etc/sudoers.d/devuser
USER devuser
ENV HOME=/home/devuser
ENV PATH=$PATH:${HOME}/go/bin
WORKDIR ${HOME}/

# Check node and npm versions
RUN node -v && npm -v