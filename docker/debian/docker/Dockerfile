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
    go install -v github.com/vegito-app/local/proxy@latest \
    && go install -v github.com/jesseduffield/lazydocker@latest 

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

ENV USER=${non_root_user}

COPY entrypoint.sh /usr/local/bin/debian-docker-entrypoint.sh
RUN chmod +x /usr/local/bin/debian-docker-entrypoint.sh

COPY dind-rootless-start.sh /usr/local/bin/debian-dind-rootless-start.sh
RUN chmod +x /usr/local/bin/debian-dind-rootless-start.sh

COPY --from=go-build /go/bin/proxy      /usr/local/bin/localproxy
COPY --from=go-build /go/bin/lazydocker /usr/local/bin/lazydocker

COPY --from=docker-dind /usr/local/bin/dockerd-entrypoint.sh  /usr/local/bin/
COPY --from=docker-dind /usr/local/bin/docker-entrypoint.sh   /usr/local/bin/
COPY --from=docker-dind /usr/local/bin/modprobe               /usr/local/bin/

USER ${non_root_user}

ENV USER=${non_root_user}

ENTRYPOINT ["tini", "--", "debian-docker-entrypoint.sh"]
HEALTHCHECK CMD test -f /tmp/.dockerd-rootless-ready || exit 1
CMD ["debian-dind-rootless-start.sh"]