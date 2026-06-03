FROM debian


ARG TARGETPLATFORM

USER root
ARG debian_version=bookworm

# RUN --mount=type=cache,id=vegito-debian-${debian_version}-${TARGETPLATFORM}-apt-cache,target=/var/cache/apt,sharing=locked \
#     --mount=type=cache,id=vegito-debian-${debian_version}-${TARGETPLATFORM}-apt-lib,target=/var/lib/apt,sharing=locked \
#     if [ "${DEBIAN_VERSION}" = "trixie" ]; then \
#     JAVA_PACKAGE=default-jdk; \
#     LIBNCURSES_PACKAGE=libncurses6; \
#     else \
#     JAVA_PACKAGE=openjdk-17-jdk; \
#     LIBNCURSES_PACKAGE=libncurses5; \
#     fi; \
#     apt-get -o Acquire::Retries=3 update && apt-get install -y \
#     build-essential \
#     g++ \
#     gcc \
#     gcc \
#     libbz2-1.0 \
#     libc6 \
#     libcairo2-dev \
#     libgif-dev \
#     libglu1-mesa \
#     libjpeg-dev \
#     libpango1.0-dev \
#     librsvg2-dev \
#     libstdc++6 \
#     lsb-release \
#     ${JAVA_PACKAGE} \
#     ${LIBNCURSES_PACKAGE}

# kubectl
ARG kubectl_version=1.32
RUN --mount=type=cache,id=local-builder-${TARGETPLATFORM}-apt-cache,target=/var/cache/apt,sharing=locked \
    --mount=type=cache,id=local-builder-${TARGETPLATFORM}-apt-lib,target=/var/lib/apt,sharing=locked \
    echo "deb [signed-by=/etc/apt/keyrings/kubernetes-apt-keyring.gpg] https://pkgs.k8s.io/core:/stable:/v${kubectl_version}/deb/ /" | tee /etc/apt/sources.list.d/kubernetes.list > /dev/null \
    && curl -fsSL https://pkgs.k8s.io/core:/stable:/v${kubectl_version}/deb/Release.key | gpg --dearmor | tee /etc/apt/keyrings/kubernetes-apt-keyring.gpg > /dev/null \
    && chmod 644 /etc/apt/keyrings/kubernetes-apt-keyring.gpg \
    && chmod 644 /etc/apt/sources.list.d/kubernetes.list \
    && apt-get -o Acquire::Retries=3 update \
    && apt-get install -y kubectl

# k9s
ARG k9s_version=0.50.9

RUN set -eu; \
    case "$TARGETPLATFORM" in \
    "linux/amd64") \
    archive="k9s_Linux_amd64.tar.gz" ;; \
    "linux/arm64") \
    archive="k9s_Linux_arm64.tar.gz" ;; \
    *) \
    echo >&2 "unsupported arch: $TARGETPLATFORM"; exit 1 ;; \
    esac; \
    curl -L \
    -o /tmp/k9s.tar.gz \
    "https://github.com/derailed/k9s/releases/download/v${k9s_version}/${archive}" \
    && tar -xzf /tmp/k9s.tar.gz -C /tmp \
    && install -m 0755 /tmp/k9s /usr/local/bin/k9s \
    && rm -rf /tmp/k9s* \
    && k9s version

# Install Helm
RUN curl -fsSL -o get_helm.sh https://raw.githubusercontent.com/helm/helm/main/scripts/get-helm-3 \
    && chmod 700 get_helm.sh \
    && ./get_helm.sh

ARG non_root_user=kubernetes
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

USER ${non_root_user}    

ENV USER=${non_root_user}

WORKDIR ${HOME}