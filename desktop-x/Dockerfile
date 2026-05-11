FROM debian_image

ENV DEBIAN_FRONTEND=noninteractive

USER root

# ⚙️ Install minimum dependencies
RUN --mount=type=cache,id=local-desktopx-${TARGETPLATFORM}-apt-cache,target=/var/cache/apt,sharing=locked \
    --mount=type=cache,id=local-desktopx-${TARGETPLATFORM}-apt-lib,target=/var/lib/apt,sharing=locked \
    apt-get -o Acquire::Retries=3 update && apt-get install -y \
    curl unzip x11vnc xvfb xinit openbox xorg xdg-utils openjdk-17-jre \
    libgtk-3-dev libvulkan1 libpulse0 libasound2 fonts-liberation \
    menu-xdg \
    weston \
    xwayland \
    wayland-protocols \
    wayland-utils \
    libnvidia-egl-wayland1 \
    libegl1 \
    libegl1-mesa \
    libgbm1 \
    sudo \
    tini \
    bash-completion git htop gnupg jq netcat-openbsd \
    rsync socat tree unzip vim wget xz-utils \
    ca-certificates wget gnupg \
    locales net-tools \
    dbus-x11 \
    && locale-gen en_US.UTF-8 \
    && dpkg-reconfigure locales

RUN --mount=type=cache,id=local-desktopx-${TARGETPLATFORM}-apt-cache,target=/var/cache/apt,sharing=locked \
    --mount=type=cache,id=local-desktopx-${TARGETPLATFORM}-apt-lib,target=/var/lib/apt,sharing=locked \
    wget -O /usr/share/keyrings/xpra.asc https://xpra.org/xpra.asc && \
    wget -O /etc/apt/sources.list.d/xpra.sources \
    https://raw.githubusercontent.com/Xpra-org/xpra/master/packaging/repos/bookworm/xpra.sources && \
    apt-get -o Acquire::Retries=3 update && apt-get install -y \
    xpra \
    xpra-codecs-nvidia

# NVIDIA
RUN  --mount=type=cache,id=local-desktopx-${TARGETPLATFORM}-apt-cache,target=/var/cache/apt,sharing=locked \
    --mount=type=cache,id=local-desktopx-${TARGETPLATFORM}-apt-lib,target=/var/lib/apt,sharing=locked \
    export DEBIAN_FRONTEND=noninteractive ; \
    sed -i 's/Components: main/Components: main contrib non-free non-free-firmware/' /etc/apt/sources.list.d/debian.sources && \
    apt-get -o Acquire::Retries=3 update && apt-get install -y \
    xserver-xorg-video-nvidia \
    nvidia-driver \
    mesa-utils \
    libgl1-mesa-dri \
    libglx-mesa0

ARG enable_audio=1
ENV ENABLE_AUDIO=${enable_audio}

RUN  --mount=type=cache,id=local-desktopx-${TARGETPLATFORM}-apt-cache,target=/var/cache/apt,sharing=locked \
    --mount=type=cache,id=local-desktopx-${TARGETPLATFORM}-apt-lib,target=/var/lib/apt,sharing=locked \
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

RUN  --mount=type=cache,id=local-desktopx-${TARGETPLATFORM}-apt-cache,target=/var/cache/apt,sharing=locked \
    --mount=type=cache,id=local-desktopx-${TARGETPLATFORM}-apt-lib,target=/var/lib/apt,sharing=locked \
    apt-get -o Acquire::Retries=3 update && apt-get install -y \
    ffmpeg \
    gstreamer1.0-libav \
    gstreamer1.0-plugins-good \
    gstreamer1.0-plugins-bad \
    gstreamer1.0-plugins-ugly \
    libx264-dev \
    x264

RUN  --mount=type=cache,id=local-desktopx-${TARGETPLATFORM}-apt-cache,target=/var/cache/apt,sharing=locked \
    --mount=type=cache,id=local-desktopx-${TARGETPLATFORM}-apt-lib,target=/var/lib/apt,sharing=locked \
    if [ "$ENABLE_AUDIO" = "1" ]; then \
    apt-get -o Acquire::Retries=3 update && apt-get install -y \
    libnotify-bin \
    pavucontrol \
    alsa-utils; \
    fi

# 👤 Create non-root user
ARG non_root_user=desktopx
ARG uid=1000
ARG gid=1000

RUN groupadd -g ${gid} ${non_root_user} \
    && useradd -m -u ${uid} -g ${gid} ${non_root_user} \
    && \
    echo "${non_root_user}:${non_root_user}" | chpasswd && \
    adduser ${non_root_user} sudo && \
    echo "${non_root_user} ALL=(ALL) NOPASSWD:ALL" > /etc/sudoers.d/${non_root_user} && \
    chmod 0440 /etc/sudoers.d/${non_root_user}

RUN mkdir -p /run/user/${uid} \
    && chown ${uid}:${gid} /run/user/${uid} \
    && chmod 700 /run/user/${uid}

# 👤 Switch to non-root user
USER ${non_root_user}
ENV HOME=/home/${non_root_user}
WORKDIR ${HOME}

COPY --chown=desktopx:desktopx display-start-xorg-host.sh /usr/local/bin/
COPY --chown=desktopx:desktopx display-start.sh           /usr/local/bin/
COPY --chown=desktopx:desktopx display-start-wayland.sh   /usr/local/bin/
COPY --chown=desktopx:desktopx openbox-setup.sh           /usr/local/bin/
COPY --chown=desktopx:desktopx enable-nvidia-gl.sh        /usr/local/bin/
COPY --chown=desktopx:desktopx nvidia-gl-env.sh           /usr/local/bin/

COPY --chown=desktopx:desktopx entrypoint.sh              /usr/local/bin/desktop-x-entrypoint.sh

RUN chmod +x \
    /usr/local/bin/desktop-x-entrypoint.sh \
    /usr/local/bin/display-start-wayland.sh \
    /usr/local/bin/display-start-xorg-host.sh \
    /usr/local/bin/display-start.sh \
    /usr/local/bin/enable-nvidia-gl.sh \
    /usr/local/bin/nvidia-gl-env.sh \
    /usr/local/bin/openbox-setup.sh

# 📱 By default, we can pass an APK already mounted in /apk/app.apk
ARG default_apk_path=/apk/app.apk
ENV LOCAL_DESKTOP_X_DEBUG_APK_PATH=${default_apk_path}

# 🖥️ Display Variables
ARG default_display=99
ENV DISPLAY=:${default_display}

# Enable AVD on start by default
ENV LOCAL_DESKTOP_X_GPU_MODE=swiftshader_indirect
ENV LOCAL_CONTAINER_DISPLAY_START=true

ENTRYPOINT ["tini", "--", "desktop-x-entrypoint.sh"]
HEALTHCHECK CMD test -f /tmp/.xdisplay-ready || exit 1