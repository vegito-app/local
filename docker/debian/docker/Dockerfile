FROM debian

ARG TARGETPLATFORM

ENV DEBIAN_FRONTEND=noninteractive

USER root

ARG docker_version

ARG TARGETPLATFORM
RUN \
    set -eu; \
    \
    mkdir -p /run/user && chmod 1777 /run/user; \
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
    'docker/containerd' \
    'docker/dockerd' \
    'docker/runc' \
    'docker/containerd-shim-runc-v2' \
    'docker/ctr' \
    'docker/docker-proxy' \
    'docker/docker-init' \
    ; \
    rm docker.tgz; \
    \
    docker --version; \
    \
    #
    # DOCKER_ROOTLESS
    # 
    \
    case "$TARGETPLATFORM" in \
    "linux/amd64") \
    url="https://download.docker.com/linux/static/test/x86_64/docker-rootless-extras-${docker_version}.tgz"; \
    ;; \
    "linux/arm64") \
    url="https://download.docker.com/linux/static/test/aarch64/docker-rootless-extras-${docker_version}.tgz"; \
    ;; \
    *) echo >&2 "error: unsupported 'rootless.tgz' architecture ($TARGETPLATFORM)"; exit 1 ;; \
    esac; \
    \
    curl -o 'rootless.tgz' -L "${url}"; \
    \
    tar --extract \
    --file rootless.tgz \
    --strip-components 1 \
    --directory /usr/local/bin/ \
    'docker-rootless-extras/rootlesskit' \
    'docker-rootless-extras/vpnkit' \
    ; \
    rm rootless.tgz; \
    \
    rootlesskit --version; \
    vpnkit --version;
