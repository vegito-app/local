ARG builder_image=europe-west1-docker.pkg.local/moov-dev-439608/docker-repository-public/moov-dev-439608:builder-latest
FROM debian:bookworm

RUN apt-get update && apt-get install -y \
    curl \
    git \
    gpg \
    make \
    unzip \
    sudo \
    wget

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
ARG terraform_version
RUN curl -OL https://releases.hashicorp.com/terraform/${terraform_version}/terraform_${terraform_version}_linux_amd64.zip \
    && unzip terraform_${terraform_version}_linux_amd64.zip -d /usr/local/bin/ \
    && rm terraform_${terraform_version}_linux_amd64.zip

# kubectl
ARG kubectl_version
RUN echo "deb [signed-by=/etc/apt/keyrings/kubernetes-apt-keyring.gpg] https://pkgs.k8s.io/core:/stable:/v${kubectl_version}/deb/ /" | tee /etc/apt/sources.list.d/kubernetes.list > /dev/null \
    && curl -fsSL https://pkgs.k8s.io/core:/stable:/v${kubectl_version}/deb/Release.key | gpg --dearmor | tee /etc/apt/keyrings/kubernetes-apt-keyring.gpg > /dev/null \
    && chmod 644 /etc/apt/keyrings/kubernetes-apt-keyring.gpg \
    && chmod 644 /etc/apt/sources.list.d/kubernetes.list \
    && apt-get update \
    && apt-get install -y kubectl \
    && rm -rf /var/lib/apt/lists/* 

# helm
RUN curl https://baltocdn.com/helm/signing.asc | gpg --dearmor | tee /usr/share/keyrings/helm.gpg > /dev/null \
    && echo "deb [arch=$(dpkg --print-architecture) signed-by=/usr/share/keyrings/helm.gpg] https://baltocdn.com/helm/stable/debian/ all main" | tee /etc/apt/sources.list.d/helm-stable-debian.list > /dev/null \
    && apt-get update \
    && apt-get install helm \ 
    && rm -rf /var/lib/apt/lists/* \
    && helm repo add hashicorp https://helm.releases.hashicorp.com \
    && helm repo update 


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

ARG non_root_user=github
ENV HOME=/home/${non_root_user}
RUN useradd -m ${non_root_user} -u 1000 && echo "${non_root_user}:${non_root_user}" | chpasswd && adduser ${non_root_user} sudo \
    && echo "${non_root_user} ALL=(ALL) NOPASSWD:ALL" > /etc/sudoers.d/${non_root_user} \
    && chmod 0440 /etc/sudoers.d/${non_root_user} \
    \
    && chown -R ${non_root_user}:${non_root_user} ${HOME}

WORKDIR ${HOME}

USER ${non_root_user}

ENV NVM_DIR=${HOME}/nvm

ARG nvm_version
ARG node_version
RUN set -x; \
    # 
    mkdir -p ${NVM_DIR} \
    # 
    && curl -o- https://raw.githubusercontent.com/nvm-sh/nvm/v${nvm_version}/install.sh | bash - \
    && . ${NVM_DIR}/nvm.sh \
    && nvm install ${node_version} \
    && nvm alias default ${node_version} \
    && nvm use default \
    # 
    && npm install -g \
    standard-version \
    npm \
    && rm -rf ${HOME}/.npm 

WORKDIR /runner

ARG github_runner_version
ENV RUNNER_VERSION=${github_runner_version}
USER root
RUN curl -O -L https://github.com/actions/runner/releases/download/v$RUNNER_VERSION/actions-runner-linux-x64-$RUNNER_VERSION.tar.gz \
    && tar xzf ./actions-runner-linux-x64-$RUNNER_VERSION.tar.gz \
    && rm -f ./actions-runner-linux-x64-$RUNNER_VERSION.tar.gz \
    && ./bin/installdependencies.sh \
    && chown -R ${non_root_user}:${non_root_user} .

USER ${non_root_user}
COPY docker-entrypoint.sh /github-entrypoint.sh
ENTRYPOINT ["/github-entrypoint.sh"]

ENV RUNNER_WORKDIR=/runner/_work
RUN mkdir ${RUNNER_WORKDIR}
VOLUME ["${RUNNER_WORKDIR}"]
