FROM debian:bookworm

ENV DEBIAN_FRONTEND=noninteractive

USER root

# ⚙️ Install minimum dependencies
RUN apt-get update && apt-get install -y \
    curl unzip x11vnc xvfb xinit openbox xorg xdg-utils openjdk-17-jre \
    libgtk-3-dev libvulkan1 libpulse0 libasound2 fonts-liberation \
    qemu-kvm sudo \
    && rm -rf /var/lib/apt/lists/*

# 👤 Create non-root user
ARG non_root_user=android
RUN useradd -m ${non_root_user} -u 1000 && \
    echo "${non_root_user}:${non_root_user}" | chpasswd && \
    adduser ${non_root_user} sudo && \
    echo "${non_root_user} ALL=(ALL) NOPASSWD:ALL" > /etc/sudoers.d/${non_root_user} && \
    chmod 0440 /etc/sudoers.d/${non_root_user}

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

# 🧪 Créer un AVD
RUN ARCH="$(dpkg --print-architecture)" && \
    if [ "$ARCH" = "amd64" ]; then \
    sdkmanager \
    "system-images;android-34;google_apis_playstore;x86_64" \
    "emulator" ; \
    echo "no" | avdmanager create avd -n Pixel_8_Intel -k "system-images;android-34;google_apis_playstore;x86_64" -d "pixel_8" ; \
    fi

# 🖥️ Variables d'affichage
ARG default_display=20
ENV DISPLAY=:${default_display}

# 📥 Entrypoint pour lancer émulateur + APK
COPY --chown=android:android display-start.sh /usr/local/bin/
COPY --chown=android:android display-start-xpra.sh /usr/local/bin/
COPY --chown=android:android entrypoint.sh /usr/local/bin/android-emulator-entrypoint.sh
COPY --chown=android:android emulator-data-load.sh /usr/local/bin/
COPY --chown=android:android openbox-setup.sh /usr/local/bin/

# Rendre les scripts exécutables
RUN chmod +x /usr/local/bin/display-start.sh \
    /usr/local/bin/display-start-xpra.sh \
    /usr/local/bin/android-emulator-entrypoint.sh \
    /usr/local/bin/emulator-data-load.sh \
    /usr/local/bin/openbox-setup.sh

# 📱 Par défaut, on peut passer un APK déjà monté dans /apk/app.apk
ARG default_apk_path=/apk/app.apk
ENV APK_PATH=${default_apk_path}
ENV LOCAL_ANDROID_GPU_MODE=swiftshader_indirect
ENV LOCAL_ANDROID_CONTAINER_DISPLAY_START=true
ENV LOCAL_ANDROID_AVD_NAME=Pixel_8_Intel

ENTRYPOINT ["android-emulator-entrypoint.sh"]