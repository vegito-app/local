FROM debian_golang AS go-build
ARG debian_version=bookworm
ARG TARGETPLATFORM

ARG go_pkg=/go/pkg
ARG go_cache=/root/.cache/go-build
ENV GOMODCACHE=${go_pkg}/mod
ENV GOCACHE=${go_cache}
ENV GOBIN=/go/bin
ENV CGO_ENABLED=0
RUN --mount=type=cache,id=vegito-debian-${TARGETPLATFORM}-${debian_version}-root-go-pkg,target=${go_pkg},sharing=locked \
    --mount=type=cache,id=vegito-debian-${TARGETPLATFORM}-${debian_version}-root-go-build,target=${go_cache},sharing=locked \
    go install -v github.com/jesseduffield/lazydocker@latest 

FROM docker_dind_rootless AS docker-dind

FROM debian
ARG debian_version=bookworm
ARG TARGETPLATFORM

USER root

RUN --mount=type=cache,id=vegito-debian-${debian_version}-${TARGETPLATFORM}-apt-cache,target=/var/cache/apt,sharing=locked \
    --mount=type=cache,id=vegito-debian-${debian_version}-${TARGETPLATFORM}-apt-lib,target=/var/lib/apt,sharing=locked \
    apt-get -o Acquire::Retries=3 update && apt-get install -y \
    fuse-overlayfs \
    iproute2 \
    iptables \
    procps \
    slirp4netns \
    uidmap

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

ARG non_root_user=docker
ARG uid=1000
ARG gid=1000

# 👤 Rename non root user
RUN usermod -l ${non_root_user} ${USER} \
    && groupmod -n ${non_root_user} ${USER} \
    && \
    echo "${non_root_user}:${non_root_user}" | chpasswd && \
    adduser ${non_root_user} sudo && \
    echo "${non_root_user} ALL=(ALL) NOPASSWD:ALL" > /etc/sudoers.d/${non_root_user} && \
    chmod 0440 /etc/sudoers.d/${non_root_user}

# Install Docker
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

# 📦 Prepare user runtime (useful for dockerd sockets)
ENV XDG_RUNTIME_DIR="/run/user/${uid}"

RUN mkdir -p ${XDG_RUNTIME_DIR} && \
    chmod 700 ${XDG_RUNTIME_DIR} && \
    chown ${uid}:${gid} ${XDG_RUNTIME_DIR}

ENV USER=${non_root_user}

COPY entrypoint.sh /usr/local/bin/debian-docker-entrypoint.sh
RUN chmod +x /usr/local/bin/debian-docker-entrypoint.sh

COPY container-install.sh /usr/local/bin/debian-docker-install.sh
RUN chmod +x /usr/local/bin/debian-docker-install.sh

COPY dind-rootless-start.sh /usr/local/bin/debian-dind-rootless-start.sh
RUN chmod +x /usr/local/bin/debian-dind-rootless-start.sh

COPY --from=go-build /go/bin/lazydocker /usr/local/bin/lazydocker

COPY --from=docker-dind /usr/local/bin/dockerd-entrypoint.sh  /usr/local/bin/
COPY --from=docker-dind /usr/local/bin/docker-entrypoint.sh   /usr/local/bin/
COPY --from=docker-dind /usr/local/bin/modprobe               /usr/local/bin/

USER ${non_root_user}

ENV USER=${non_root_user}

ENTRYPOINT ["tini", "--", "debian-docker-entrypoint.sh"]
CMD ["debian-dind-rootless-start.sh"]
HEALTHCHECK CMD test -f /tmp/.dockerd-rootless-ready || exit 1