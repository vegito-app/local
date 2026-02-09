ARG go_image=golang-alpine:latest
ARG debian_image=debian:latest

FROM ${go_image} AS go-build

COPY proxy proxy

RUN cd proxy \
    && GOBIN=/usr/local/bin go install -v

FROM ${debian_image}

COPY --from=go-build /usr/local/bin/proxy /usr/local/bin/localproxy

RUN apt-get update && apt-get install -y \
    apt-transport-https \
    bash-completion \
    btop \
    build-essential \
    ca-certificates \
    curl \
    dnsutils \
    file \
    g++ \
    gcc \
    gcc \
    git \
    gnupg \
    htop \
    iftop \
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
    rsync \
    socat \
    sudo \
    tree \
    unzip \
    vim \
    wget \
    xz-utils \
    zip \
    zsh \
    && rm -rf /var/lib/apt/lists/*

ARG oh_my_zsh_version=1.2.1
RUN sh -c "$(wget -O- https://github.com/deluan/zsh-in-docker/releases/download/v${oh_my_zsh_version}/zsh-in-docker.sh)"

ARG TARGETPLATFORM

# GCP CLI
RUN echo "deb [signed-by=/usr/share/keyrings/cloud.google.gpg] https://packages.cloud.google.com/apt cloud-sdk main" | \
    tee -a /etc/apt/sources.list.d/google-cloud-sdk.list \
    && curl https://packages.cloud.google.com/apt/doc/apt-key.gpg | gpg --dearmor -o /usr/share/keyrings/cloud.google.gpg \
    && apt-get update && apt-get install -y \
    google-cloud-cli-gke-gcloud-auth-plugin \
    google-cloud-sdk \
    && rm -rf /var/lib/apt/lists/* 

# Terraform
ARG terraform_version=1.11.2
RUN curl -OL https://releases.hashicorp.com/terraform/${terraform_version}/terraform_${terraform_version}_linux_amd64.zip \
    && unzip terraform_${terraform_version}_linux_amd64.zip -d /usr/local/bin/ \
    && rm terraform_${terraform_version}_linux_amd64.zip

# kubectl
ARG kubectl_version=1.32
RUN echo "deb [signed-by=/etc/apt/keyrings/kubernetes-apt-keyring.gpg] https://pkgs.k8s.io/core:/stable:/v${kubectl_version}/deb/ /" | tee /etc/apt/sources.list.d/kubernetes.list > /dev/null \
    && curl -fsSL https://pkgs.k8s.io/core:/stable:/v${kubectl_version}/deb/Release.key | gpg --dearmor | tee /etc/apt/keyrings/kubernetes-apt-keyring.gpg > /dev/null \
    && chmod 644 /etc/apt/keyrings/kubernetes-apt-keyring.gpg \
    && chmod 644 /etc/apt/sources.list.d/kubernetes.list \
    && apt-get update \
    && apt-get install -y kubectl \
    && rm -rf /var/lib/apt/lists/* 

# k9s
ARG k9s_version=0.50.9
RUN case "$TARGETPLATFORM" in \
    "linux/amd64") \
    url="https://github.com/derailed/k9s/releases/download/v${k9s_version}/k9s_linux_amd64.deb" ; \
    ;; \
    "linux/arm64") \
    url="https://github.com/derailed/k9s/releases/download/v${k9s_version}/k9s_linux_arm64.deb" ; \
    ;; \
    *) echo >&2 "error: unsupported 'k9s' architecture ($TARGETPLATFORM)"; exit 1 ;; \
    esac; \
    curl -Lo /tmp/k9s.deb $url && apt install /tmp/k9s.deb && rm /tmp/k9s.deb; \
    k9s version

# Install Helm
RUN curl -fsSL -o get_helm.sh https://raw.githubusercontent.com/helm/helm/main/scripts/get-helm-3 \
    && chmod 700 get_helm.sh \
    && ./get_helm.sh

ARG go_version
RUN case "$TARGETPLATFORM" in \
    "linux/amd64") \
    archive="go${go_version}.linux-amd64.tar.gz" ; \
    ;; \
    "linux/arm64") \
    archive="go${go_version}.linux-arm64.tar.gz" ; \
    ;; \
    esac \
    && curl -o- https://dl.google.com/go/${archive} | tar xz -C /usr/local --

ENV CGO_ENABLED=1
ENV PATH=${PATH}:/usr/local/go/bin

ARG docker_version
ARG docker_compose_version
ARG docker_buildx_version
RUN \
    set -eu; \
    \
    case "$TARGETPLATFORM" in \
    "linux/amd64") \
    url="https://download.docker.com/linux/static/stable/x86_64/docker-${docker_version}.tgz"; \
    ;; \
    "linux/arm64") \
    url="https://download.docker.com/linux/static/stable/aarch64/docker-${docker_version}.tgz"; \
    ;; \
    *) echo >&2 "error: unsupported 'docker.tgz' architecture ($TARGETPLATFORM)"; exit 1 ;; \
    esac; \
    wget -O 'docker.tgz' "$url";  \
    \
    tar --extract \
    --file docker.tgz \
    --strip-components 1 \
    --directory /usr/local/bin/ \
    --no-same-owner \
    'docker/docker' \
    ; \
    rm docker.tgz; \
    \
    docker --version; \
    # 
    # Docker Buildx 
    # 
    case "$TARGETPLATFORM" in \
    "linux/amd64") \
    url="https://github.com/docker/buildx/releases/download/v${docker_buildx_version}/buildx-v${docker_buildx_version}.linux-amd64"; \
    sha256='805195386fba0cea5a1487cf0d47da82a145ea0a792bd3fb477583e2dbcdcc2f'; \
    ;; \
    "linux/arm64") \
    url="https://github.com/docker/buildx/releases/download/v${docker_buildx_version}/buildx-v${docker_buildx_version}.linux-arm64"; \
    sha256='6e9e455b5ec1c7ac708f2640a86c5cecce38c72e48acff6cb219dfdfa2dda781'; \
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
    # Docker Compose
    # 
    \
    case "$TARGETPLATFORM" in \
    "linux/amd64") \
    url="https://github.com/docker/compose/releases/download/v${docker_compose_version}/docker-compose-linux-x86_64"; \
    sha256='94a416c6f2836a0a1ba5eb3feb00f2e700a9d98311f062c4c61494ccbf3cd457'; \
    ;; \
    "linux/arm64") \
    url="https://github.com/docker/compose/releases/download/v${docker_compose_version}/docker-compose-linux-aarch64"; \
    sha256='cd1ef5eda1119edb9314c0224bac97cee14a9c31909a0f7aa0ddfe266e08adaa'; \
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

ARG non_root_user=vegito

RUN useradd -m ${non_root_user} -u 1000 && echo "${non_root_user}:${non_root_user}" | chpasswd && adduser ${non_root_user} sudo \
    && echo "${non_root_user} ALL=(ALL) NOPASSWD:ALL" > /etc/sudoers.d/${non_root_user} \
    && chmod 0440 /etc/sudoers.d/${non_root_user} \
    \
    && chown -R ${non_root_user}:${non_root_user} ${HOME}

ENV HOME=/home/${non_root_user}

WORKDIR ${HOME}

ENV PATH=${PATH}:${HOME}/go/bin

ENV NVM_DIR=${HOME}/nvm

ARG nvm_version
ARG node_version
RUN set -e ; \
    # 
    mkdir -p ${NVM_DIR} ; \
    #
    curl -o- https://raw.githubusercontent.com/nvm-sh/nvm/v${nvm_version}/install.sh | bash - ; \
    . ${NVM_DIR}/nvm.sh ; \
    nvm install ${node_version} ; \
    nvm alias default ${node_version} ; \
    nvm use default ;  \
    # 
    npm install -g \
    depcheck \
    firebase-tools \
    npm-check-updates \
    npm-check \
    npm \
    @devcontainers/cli ; \
    rm -rf ${HOME}/.npm 

ENV NODE_PATH=$NVM_DIR/versions/node/v${node_version}/lib/node_modules
ENV PATH=$NVM_DIR/versions/node/v${node_version}/bin:$PATH

RUN apt-get update && apt-get install -y \
    emacs-nox \
    && apt-get clean && rm -rf /var/lib/apt/lists/*

USER ${non_root_user}

RUN emacs --batch --eval "(require 'package)" \
    --eval "(add-to-list 'package-archives '(\"melpa\" . \"https://melpa.org/packages/\"))" \
    --eval "(package-initialize)" \
    --eval "(unless package-archive-contents (package-refresh-contents))" \
    --eval "(package-install 'magit)"
# Go tools
RUN GOPATH=/tmp/go GOBIN=${HOME}/bin bash -c " \
    go install -v golang.org/x/tools/gopls@latest \
    && go install -v github.com/cweill/gotests/gotests@v1.6.0 \
    && go install -v github.com/josharian/impl@v1.4.0 \
    && go install -v github.com/haya14busa/goplay/cmd/goplay@v1.0.0 \
    && go install -v github.com/go-delve/delve/cmd/dlv@latest \
    && go install -v honnef.co/go/tools/cmd/staticcheck@latest \
    && go install -v github.com/jesseduffield/lazydocker@latest \
    "

ENV PATH=${HOME}/bin:$PATH

USER root
ARG gitleaks_version=8.28.0

RUN case "$TARGETPLATFORM" in "linux/amd64") \
    url="https://github.com/gitleaks/gitleaks/releases/download/v${gitleaks_version}/gitleaks_${gitleaks_version}_linux_x64.tar.gz" ; \
    ;; \
    "linux/arm64") \
    url="https://github.com/gitleaks/gitleaks/releases/download/v${gitleaks_version}/gitleaks_${gitleaks_version}_linux_arm64.tar.gz" ; \
    ;; \
    *) echo >&2 "warning: unsupported 'gitleaks' architecture ($TARGETPLATFORM); skipping"; exit 0 ;; \
    esac; \
    echo "Downloading gitleaks from $url"; \
    curl -L -o /tmp/gitleaks.tar.gz $url \
    && mkdir -p /tmp/gitleaks \
    && tar -xvzf /tmp/gitleaks.tar.gz -C /tmp/gitleaks \
    && mv /tmp/gitleaks/gitleaks /usr/local/bin/gitleaks \
    && rm -rf /tmp/gitleaks \
    && gitleaks version

RUN ln -sf /usr/bin/bash /bin/sh

USER ${non_root_user}

COPY container-install.sh /usr/local/bin/local-container-install.sh

COPY entrypoint.sh /usr/local/bin/dev-entrypoint.sh
ENTRYPOINT [ "dev-entrypoint.sh" ]

# oapi-codegen
RUN go install github.com/oapi-codegen/oapi-codegen/v2/cmd/oapi-codegen@latest