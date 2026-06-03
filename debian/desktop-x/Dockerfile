FROM debian
ARG debian_version=bookworm
ARG TARGETPLATFORM

USER root

# ⚙️ Install minimum dependencies
RUN --mount=type=cache,id=vegito-debian-${debian_version}-${TARGETPLATFORM}-apt-cache,target=/var/cache/apt,sharing=locked \
    --mount=type=cache,id=vegito-debian-${debian_version}-${TARGETPLATFORM}-apt-lib,target=/var/lib/apt,sharing=locked \
    if [ "${debian_version}" = "trixie" ]; then \
    JAVA_PACKAGE=default-jre; \
    EGL_PACKAGE=libegl-mesa0; \
    else \
    JAVA_PACKAGE=openjdk-17-jre; \
    EGL_PACKAGE=libegl1-mesa; \
    fi; \
    apt-get -o Acquire::Retries=3 update && apt-get install -y \
    dbus-x11 \
    libegl1 \
    ${EGL_PACKAGE} \
    libgbm1 \
    libgtk-3-dev libvulkan1 fonts-liberation \
    libnvidia-egl-wayland1 \
    menu-xdg \
    openbox \
    pipx \
    ${JAVA_PACKAGE} \
    wayland-protocols \
    wayland-utils \
    weston \
    x11vnc \
    xdg-utils \
    xinit \
    xorg \
    xvfb \
    xwayland 

RUN --mount=type=cache,id=vegito-debian-${debian_version}-${TARGETPLATFORM}-apt-cache,target=/var/cache/apt,sharing=locked \
    --mount=type=cache,id=vegito-debian-${debian_version}-${TARGETPLATFORM}-apt-lib,target=/var/lib/apt,sharing=locked \
    curl -o /usr/share/keyrings/xpra.asc \
    -L https://xpra.org/xpra.asc && \
    curl -o /etc/apt/sources.list.d/xpra.sources \
    -L https://raw.githubusercontent.com/Xpra-org/xpra/master/packaging/repos/${debian_version}/xpra.sources && \
    apt-get -o Acquire::Retries=3 update && apt-get install -y \
    xpra \
    xpra-codecs-nvidia

# NVIDIA
RUN  --mount=type=cache,id=vegito-debian-${debian_version}-${TARGETPLATFORM}-apt-cache,target=/var/cache/apt,sharing=locked \
    --mount=type=cache,id=vegito-debian-${debian_version}-${TARGETPLATFORM}-apt-lib,target=/var/lib/apt,sharing=locked \
    # sed -i 's/Components: main/Components: main contrib non-free non-free-firmware/' /etc/apt/sources.list.d/debian.sources && \
    apt-get -o Acquire::Retries=3 update && apt-get install -y \
    nvtop \
    mesa-utils \
    libgl1-mesa-dri \
    libglx-mesa0 \
    libglvnd0 \
    libglx0 \
    libegl1
# Do not install the following packages, as they are not compatible with the current version of the NVIDIA driver
# Those packages are injected into the container by the nvidia-container-runtime
# xserver-xorg-video-nvidia \
# nvidia-driver \
# nvidia-driver-libs
# nvidia-smi
# nvidia-kernel-dkms

ARG enable_audio=1
ENV ENABLE_AUDIO=${enable_audio}

RUN  --mount=type=cache,id=vegito-debian-${debian_version}-${TARGETPLATFORM}-apt-cache,target=/var/cache/apt,sharing=locked \
    --mount=type=cache,id=vegito-debian-${debian_version}-${TARGETPLATFORM}-apt-lib,target=/var/lib/apt,sharing=locked \
    if [ "$ENABLE_AUDIO" = "1" ]; then \
    apt-get -o Acquire::Retries=3 update && apt-get install -y \
    pulseaudio pulseaudio-utils \
    gstreamer1.0-tools \
    gstreamer1.0-plugins-base \
    gstreamer1.0-plugins-good \
    gstreamer1.0-plugins-bad \
    gstreamer1.0-plugins-ugly \
    python3-gi \
    python3-gst-1.0 \
    gir1.2-gstreamer-1.0 \
    gir1.2-gst-plugins-base-1.0 ; \
    fi

RUN  --mount=type=cache,id=vegito-debian-${debian_version}-${TARGETPLATFORM}-apt-cache,target=/var/cache/apt,sharing=locked \
    --mount=type=cache,id=vegito-debian-${debian_version}-${TARGETPLATFORM}-apt-lib,target=/var/lib/apt,sharing=locked \
    apt-get -o Acquire::Retries=3 update && apt-get install -y \
    ffmpeg \
    gstreamer1.0-libav \
    gstreamer1.0-plugins-good \
    gstreamer1.0-plugins-bad \
    gstreamer1.0-plugins-ugly \
    libx264-dev \
    x264

RUN  --mount=type=cache,id=vegito-debian-${debian_version}-${TARGETPLATFORM}-apt-cache,target=/var/cache/apt,sharing=locked \
    --mount=type=cache,id=vegito-debian-${debian_version}-${TARGETPLATFORM}-apt-lib,target=/var/lib/apt,sharing=locked \
    if [ "$ENABLE_AUDIO" = "1" ]; then \
    apt-get -o Acquire::Retries=3 update && apt-get install -y \
    alsa-utils \
    libasound2 \
    libnotify-bin \
    libpulse0 \
    pavucontrol; \
    fi

ARG non_root_user=desktopx
ARG uid=1000
ARG gid=1000

# NodeJS for Appium
RUN curl -fsSL https://deb.nodesource.com/setup_20.x | bash - && \
    apt-get install -y nodejs 

# Google Chrome ou Chromium selon arch
RUN --mount=type=cache,id=vegito-debian-${debian_version}-${TARGETPLATFORM}-apt-cache,target=/var/cache/apt,sharing=locked \
    --mount=type=cache,id=vegito-debian-${debian_version}-${TARGETPLATFORM}-apt-lib,target=/var/lib/apt,sharing=locked \
    ARCH="$(dpkg --print-architecture)" && \
    if [ "$ARCH" = "amd64" ]; then \
    curl -OL https://dl.google.com/linux/direct/google-chrome-stable_current_amd64.deb && \
    dpkg -i google-chrome-stable_current_amd64.deb && \
    apt-get install -f -y && rm google-chrome-stable_current_amd64.deb ; \
    else \
    apt-get -o Acquire::Retries=3 update && apt-get install -y chromium ; \
    fi

# 👤 Rename non root user
RUN usermod -l ${non_root_user} ${USER} \
    && groupmod -n ${non_root_user} ${USER} \
    && \
    echo "${non_root_user}:${non_root_user}" | chpasswd && \
    adduser ${non_root_user} sudo && \
    echo "${non_root_user} ALL=(ALL) NOPASSWD:ALL" > /etc/sudoers.d/${non_root_user} && \
    chmod 0440 /etc/sudoers.d/${non_root_user}

ENV USER=${non_root_user}

# 📦 Prepare user runtime (useful for xpra / weston / pulseaudio sockets)
ENV XDG_RUNTIME_DIR="/run/user/${uid}"

RUN mkdir -p ${XDG_RUNTIME_DIR} && \
    chmod 700 ${XDG_RUNTIME_DIR} && \
    chown ${uid}:${gid} ${XDG_RUNTIME_DIR}

# Make /bin/sh point to bash (and not dash)
RUN ln -sf /usr/bin/bash /bin/sh

# 👤 Switch to non-root user
USER ${non_root_user}

WORKDIR ${HOME}

# Install nvidia tools for monitoring GPU usage
RUN --mount=type=cache,id=vegito-debian-${debian_version}-${TARGETPLATFORM}-python-build,target=/home/debian/.cache,sharing=locked,uid=${uid},gid=${gid} \
    pipx ensurepath \
    && pipx install nvitop

ENV PATH=${PATH}:/home/debian/.local/bin

COPY --chown=${non_root_user}:${non_root_user} xdisplay/xvfb-display-start.sh     /usr/local/bin/
COPY --chown=${non_root_user}:${non_root_user} xdisplay/xorg-display-start.sh     /usr/local/bin/
COPY --chown=${non_root_user}:${non_root_user} xdisplay/xwayland-display-start.sh /usr/local/bin/
COPY --chown=${non_root_user}:${non_root_user} xdisplay/xpra-start.sh             /usr/local/bin/

COPY --chown=${non_root_user}:${non_root_user} enable-nvidia-gl.sh /usr/local/bin/
COPY --chown=${non_root_user}:${non_root_user} nvidia-gl-env.sh    /usr/local/bin/

COPY --chown=${non_root_user}:${non_root_user} entrypoint.sh         /usr/local/bin/desktop-x-entrypoint.sh
COPY --chown=${non_root_user}:${non_root_user} container-install.sh  /usr/local/bin/desktop-x-install.sh
COPY --chown=${non_root_user}:${non_root_user} container-start.sh    /usr/local/bin/desktop-x-start.sh

RUN chmod +x \
    /usr/local/bin/desktop-x-entrypoint.sh \
    /usr/local/bin/desktop-x-start.sh \
    /usr/local/bin/enable-nvidia-gl.sh \
    /usr/local/bin/nvidia-gl-env.sh \
    /usr/local/bin/xorg-display-start.sh \
    /usr/local/bin/xpra-start.sh \
    /usr/local/bin/xvfb-display-start.sh \
    /usr/local/bin/xwayland-display-start.sh

# 📱 By default, we can pass an APK already mounted in /apk/app.apk
ARG default_apk_path=/apk/app.apk
ENV VEGITO_DOCKER_DEBIAN_DESKTOP_X_DEBUG_APK_PATH=${default_apk_path}

# 🖥️ Display Variables
ARG default_display=99
ENV DISPLAY=:${default_display}

# Enable AVD on start by default
ENV VEGITO_DOCKER_DEBIAN_DESKTOP_X_GPU_MODE=swiftshader_indirect
ENV VEGITO_CONTAINER_DISPLAY_START=true

ENTRYPOINT ["tini", "--", "desktop-x-entrypoint.sh"]
CMD ["desktop-x-start.sh"]
HEALTHCHECK CMD test -f /tmp/.xdisplay-ready || exit 1
ENV USER=${non_root_user}