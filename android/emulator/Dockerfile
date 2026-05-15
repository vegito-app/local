FROM debian

USER root

ARG non_root_user=android-emulator
ARG uid=1000
ARG gid=1000

# 👤 Rename non root user
RUN usermod -l ${non_root_user} desktopx \
    && groupmod -n ${non_root_user} desktopx \
    && \
    echo "${non_root_user}:${non_root_user}" | chpasswd && \
    adduser ${non_root_user} sudo && \
    echo "${non_root_user} ALL=(ALL) NOPASSWD:ALL" > /etc/sudoers.d/${non_root_user} && \
    chmod 0440 /etc/sudoers.d/${non_root_user}

USER ${non_root_user}

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

COPY --chown=${uid}:${gid} avd-start.sh /usr/local/bin/android-emulator-avd-start.sh
COPY --chown=${uid}:${gid} emulator-data-load.sh /usr/local/bin/
COPY --chown=${uid}:${gid} entrypoint.sh /usr/local/bin/android-emulator-entrypoint.sh

RUN chmod +x \
    /usr/local/bin/android-emulator-avd-start.sh \
    /usr/local/bin/android-emulator-entrypoint.sh \
    /usr/local/bin/display-start-xorg-host.sh \
    /usr/local/bin/display-start.sh \
    /usr/local/bin/emulator-data-load.sh

# 📱 By default, we can pass an APK already mounted in /apk/app.apk
ARG default_apk_path=/apk/app.apk
ENV LOCAL_ANDROID_DEBUG_APK_PATH=${default_apk_path}

# 🖥️ Display Variables
ARG default_display=20
ENV DISPLAY=:${default_display}

# Enable AVD on start by default
ENV LOCAL_ANDROID_EMULATOR_AVD_ON_START=true
ENV LOCAL_ANDROID_EMULATOR_AVD_NAME=Pixel_8_Intel
ENV LOCAL_ANDROID_EMULATOR_DATA=tests/mobile_images

ENTRYPOINT ["android-emulator-entrypoint.sh"]
CMD [ "android-emulator-avd-start.sh" ]