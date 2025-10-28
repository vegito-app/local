ARG local_docker_hub_repository_private=europe-west1-docker.pkg.dev/moov-dev-439608/docker-repository-private

FROM ${local_docker_hub_repository_private}/debian:latest

ENV DEBIAN_FRONTEND=noninteractive

USER root

# ⚙️ Install minimum dependencies
RUN apt-get update && apt-get install -y \
    curl unzip x11vnc xvfb xinit openbox xorg xdg-utils openjdk-17-jre \
    libgtk-3-dev libvulkan1 libpulse0 libasound2 fonts-liberation \
    menu-xdg xpra \
    qemu-kvm aapt sudo \
    && rm -rf /var/lib/apt/lists/*

# NVIDIA
RUN export DEBIAN_FRONTEND=noninteractive ; \
    sed -i 's/Components: main/Components: main contrib non-free non-free-firmware/' /etc/apt/sources.list.d/debian.sources && \
    apt-get update && apt-get install -y \
    xserver-xorg-video-nvidia nvidia-driver mesa-utils

# 👤 Create non-root user
ARG non_root_user=android
RUN useradd -m ${non_root_user} -u 1000 && \
    echo "${non_root_user}:${non_root_user}" | chpasswd && \
    adduser ${non_root_user} sudo && \
    echo "${non_root_user} ALL=(ALL) NOPASSWD:ALL" > /etc/sudoers.d/${non_root_user} && \
    chmod 0440 /etc/sudoers.d/${non_root_user}

# 👤 Switch to non-root user
USER ${non_root_user}
ENV HOME=/home/${non_root_user}
WORKDIR ${HOME}

# 📦 Android SDK (without build-tools or NDK)
ENV ANDROID_SDK=${HOME}/Android/Sdk
ENV ANDROID_HOME=${ANDROID_SDK}
ENV PATH=${PATH}:${ANDROID_SDK}/cmdline-tools/latest/bin:${ANDROID_SDK}/emulator:${ANDROID_SDK}/platform-tools

RUN mkdir -p $ANDROID_SDK/cmdline-tools && \
    curl -o sdk.zip -L https://dl.google.com/android/repository/commandlinetools-linux-13114758_latest.zip && \
    unzip sdk.zip -d $ANDROID_SDK/cmdline-tools && rm sdk.zip && \
    mv $ANDROID_SDK/cmdline-tools/cmdline-tools $ANDROID_SDK/cmdline-tools/latest && \
    yes | sdkmanager --licenses && \
    sdkmanager \
    "platform-tools" \
    "platforms;android-34"

# 🧪 AVD installation (x86_64 only for now)
RUN ARCH="$(dpkg --print-architecture)" && \
    if [ "$ARCH" = "amd64" ]; then \
    sdkmanager \
    "system-images;android-34;google_apis_playstore;x86_64" \
    "emulator" ; \
    echo "no" | avdmanager create avd -n Pixel_8_Intel -k "system-images;android-34;google_apis_playstore;x86_64" -d "pixel_8" ; \
    fi

COPY --chown=android:android avd-start.sh /usr/local/bin/android-emulator-avd-start.sh
COPY --chown=android:android display-start-xorg-host.sh /usr/local/bin/
COPY --chown=android:android display-start.sh /usr/local/bin/
COPY --chown=android:android emulator-data-load.sh /usr/local/bin/
COPY --chown=android:android entrypoint.sh /usr/local/bin/android-emulator-entrypoint.sh
COPY --chown=android:android openbox-setup.sh /usr/local/bin/

RUN chmod +x \
    /usr/local/bin/android-emulator-avd-start.sh \
    /usr/local/bin/android-emulator-entrypoint.sh \
    /usr/local/bin/display-start-xorg-host.sh \
    /usr/local/bin/display-start.sh \
    /usr/local/bin/emulator-data-load.sh \
    /usr/local/bin/openbox-setup.sh

# 📱 By default, we can pass an APK already mounted in /apk/app.apk
ARG default_apk_path=/apk/app.apk
ENV LOCAL_ANDROID_DEBUG_APK_PATH=${default_apk_path}

# 🖥️ Display Variables
ARG default_display=20
ENV DISPLAY=:${default_display}

ENV LOCAL_ANDROID_EMULATOR_AVD_ON_START=true
ENV LOCAL_ANDROID_AVD_NAME=Pixel_8_Intel
ENV LOCAL_ANDROID_EMULATOR_DATA=tests/mobile_images
ENV LOCAL_ANDROID_GPU_MODE=swiftshader_indirect
ENV LOCAL_ANDROID_CONTAINER_DISPLAY_START=true

ENTRYPOINT ["android-emulator-entrypoint.sh"]