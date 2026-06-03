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

# Terraform
ARG terraform_version=1.11.2
RUN curl -OL https://releases.hashicorp.com/terraform/${terraform_version}/terraform_${terraform_version}_linux_amd64.zip \
    && unzip terraform_${terraform_version}_linux_amd64.zip -d /usr/local/bin/ \
    && rm terraform_${terraform_version}_linux_amd64.zip

ARG non_root_user=local
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


