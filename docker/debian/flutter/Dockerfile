FROM debian

USER root

ARG TARGETPLATFORM

ARG debian_version=bookworm
# Adding Android build tools
# clang, cmake, ninja-build : for native build (NDK)
# openjdk-17-jdk : for Android tools (sdkmanager, avdmanager, etc.)
RUN --mount=type=cache,id=vegito-debian-${debian_version}-${TARGETPLATFORM}-apt-cache,target=/var/cache/apt,sharing=locked \
    --mount=type=cache,id=vegito-debian-${debian_version}-${TARGETPLATFORM}-apt-lib,target=/var/lib/apt,sharing=locked \
    if [ "${DEBIAN_VERSION}" = "trixie" ]; then \
    JAVA_PACKAGE=default-jdk; \
    else \
    JAVA_PACKAGE=openjdk-17-jdk; \
    fi; \
    apt-get -o Acquire::Retries=3 update && apt-get install -y \
    clang cmake ninja-build ${JAVA_PACKAGE}

ARG non_root_user=flutter
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

# Flutter SDK
ARG flutter_version
ENV FLUTTER_HOME=${HOME}/flutter
ENV PATH="${PATH}:${FLUTTER_HOME}/bin"
# tar -xf ~/Downloads/flutter_linux_${flutter_version}-stable.tar.xz -C ~/home/${non_root_user}
RUN git clone -b stable https://github.com/flutter/flutter.git $FLUTTER_HOME && \
    cd $FLUTTER_HOME && \
    git checkout $flutter_version && \
    flutter config --no-analytics && \
    flutter precache && \
    flutter doctor
