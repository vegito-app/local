FROM debian:bookworm

ARG TARGETPLATFORM

ENV DEBIAN_FRONTEND=noninteractive

USER root

RUN --mount=type=cache,id=local-debian-${TARGETPLATFORM}-apt-cache,target=/var/cache/apt,sharing=locked \
    --mount=type=cache,id=local-debian-${TARGETPLATFORM}-apt-lib,target=/var/lib/apt,sharing=locked \
    apt-get -o Acquire::Retries=3 update && apt-get install -y \
    apt-transport-https \
    bash-completion \
    btop \
    ca-certificates \
    curl \
    dnsutils \
    file \
    git \
    gnupg \
    htop \
    iftop \
    iptables \
    jq \
    locales \
    lsof \
    make \
    net-tools \
    netcat-openbsd \
    procps \
    rsync \
    socat \
    sudo \
    tini \
    tmux \
    tree \
    unzip \
    vim \
    wget \
    xz-utils \
    zip \
    zsh

ARG oh_my_zsh_version=1.2.1
RUN sh -c "$(wget -O- https://github.com/deluan/zsh-in-docker/releases/download/v${oh_my_zsh_version}/zsh-in-docker.sh)"

ARG locales="en_US.UTF-8 fr_FR.UTF-8"

RUN set eu; \
    rm -f /etc/locale.gen; \
    for locale in ${locales}; do \
    echo "${locale} UTF-8" >> /etc/locale.gen; \
    done; \
    locale-gen

ENV LANG=C.UTF-8
ENV LC_ALL=C.UTF-8

ARG non_root_user=debian
ARG uid=1000
ARG gid=1000

RUN groupadd -g ${gid} ${non_root_user} \
    && useradd -m -u ${uid} -g ${gid} ${non_root_user} \
    && echo "${non_root_user}:${non_root_user}" | chpasswd && adduser ${non_root_user} sudo \
    && echo "${non_root_user} ALL=(ALL) NOPASSWD:ALL" > /etc/sudoers.d/${non_root_user} \
    && chmod 0440 /etc/sudoers.d/${non_root_user}

USER ${non_root_user}

ENV USER=${non_root_user}
ENV HOME=/home/${non_root_user}
