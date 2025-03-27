ARG builder_image=europe-west1-docker.pkg.dev/moov-438615/docker-repository-public/moov-438615:builder
FROM docker:dind-rootless AS docker
FROM ${builder_image}

COPY --from=docker /usr/local/bin/dockerd-entrypoint.sh /usr/local/bin/
COPY --from=docker /usr/local/bin/docker-entrypoint.sh /usr/local/bin/
COPY --from=docker /usr/local/bin/modprobe /usr/local/bin/

USER root

ARG TARGETPLATFORM
RUN \
    set -eux; \
    \
    mkdir -p /run/user && chmod 1777 /run/user; \
    \ 
    case "$TARGETPLATFORM" in \
    "linux/amd64") \
    url="https://download.docker.com/linux/static/stable/x86_64/docker-${DOCKER_VERSION}.tgz"; \
    ;; \
    "linux/arm64") \
    url="https://download.docker.com/linux/static/stable/aarch64/docker-${DOCKER_VERSION}.tgz"; \
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
    url="https://download.docker.com/linux/static/test/x86_64/docker-rootless-extras-${DOCKER_VERSION}.tgz"; \
    ;; \
    "linux/arm64") \
    url="https://download.docker.com/linux/static/test/aarch64/docker-rootless-extras-${DOCKER_VERSION}.tgz"; \
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
    'docker-rootless-extras/vpnkit' \
    ; \
    rm rootless.tgz; \
    \
    rootlesskit --version; \
    vpnkit --version;

RUN apt-get update && apt-get install -y uidmap iproute2 iptables

ARG clarinet_version=2.12.0
RUN wget -nv "https://github.com/hirosystems/clarinet/releases/download/v${clarinet_version}/clarinet-linux-x64-glibc.tar.gz" -O clarinet-linux-x64.tar.gz && \
    tar -xf clarinet-linux-x64.tar.gz && \
    chmod +x ./clarinet && \
    mv ./clarinet /usr/local/bin && \
    clarinet completion bash && \
    mv clarinet.bash /etc/bash_completion.d/clarinet.bash && \
    echo 'source /etc/bash_completion.d/clarinet.bash' >> ~/.bashrc

ARG non_root_user=devuser
RUN mkdir -p /home/${non_root_user}/.local/share/docker
VOLUME /home/${non_root_user}/.local/share/docker
USER ${non_root_user}
