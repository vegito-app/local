FROM debian:bookworm

# Section 1 : Dépendances système
RUN apt-get update && apt-get install -y \
  bash-completion curl git htop gnupg jq netcat-openbsd \
  make rsync socat sudo tree unzip vim wget xz-utils \
  x11vnc xvfb xinit openbox xorg xdg-utils menu-xdg net-tools xpra \
  clang cmake ninja-build openjdk-17-jdk libgtk-3-dev \
  fonts-liberation libvulkan1 libpulse0 libasound2 locales \
  && rm -rf /var/lib/apt/lists/* && dpkg-reconfigure locales

# Section 2 : NVIDIA (si supporté)
RUN\
  export DEBIAN_FRONTEND=noninteractive ; \
  sed -i 's/Components: main/Components: main contrib non-free non-free-firmware/' /etc/apt/sources.list.d/debian.sources && \
  apt-get update && apt-get install -y \
  xserver-xorg-video-nvidia nvidia-driver mesa-utils

# Section 3 : NodeJS pour Appium
RUN curl -fsSL https://deb.nodesource.com/setup_18.x | bash - && \
  apt-get install -y nodejs

# Section 4 : Google Chrome ou Chromium selon arch
RUN ARCH="$(dpkg --print-architecture)" && \
  if [ "$ARCH" = "amd64" ]; then \
  curl -OL https://dl.google.com/linux/direct/google-chrome-stable_current_amd64.deb && \
  dpkg -i google-chrome-stable_current_amd64.deb && \
  apt-get install -f -y && rm google-chrome-stable_current_amd64.deb ; \
  else \
  apt-get update && apt-get install -y chromium ; \
  fi

# Section 5 : User non-root
ARG non_root_user=android
RUN useradd -m ${non_root_user} -u 1000 && echo "${non_root_user}:${non_root_user}" | chpasswd && adduser ${non_root_user} sudo && \
  echo "${non_root_user} ALL=(ALL) NOPASSWD:ALL" > /etc/sudoers.d/${non_root_user} && chmod 0440 /etc/sudoers.d/${non_root_user}

RUN ln -sf /usr/bin/bash /bin/sh
USER ${non_root_user}
ENV HOME=/home/${non_root_user}
WORKDIR ${HOME}

# Section 6 : Flutter
ENV PATH=${PATH}:${HOME}/flutter/bin
ARG flutter_version
RUN git clone -b ${flutter_version} https://github.com/flutter/flutter.git && flutter doctor

# Section 7 : Android SDK & Appium
ENV ANDROID_SDK=${HOME}/Android/Sdk
ENV PATH=${PATH}:${ANDROID_SDK}/cmdline-tools/latest/bin:${ANDROID_SDK}/emulator:${ANDROID_SDK}/tools:${ANDROID_SDK}/tools/bin:${ANDROID_SDK}/platform-tools
ENV ANDROID_HOME=${ANDROID_SDK}
ARG android_ndk_version
RUN ANDROID_COMMANDLINETOOLS_URL=https://dl.google.com/android/repository/commandlinetools-linux-13114758_latest.zip; \
  mkdir -p $ANDROID_SDK/cmdline-tools/ && \
  cd $ANDROID_SDK/cmdline-tools/ && \
  curl -o sdk.zip -L $ANDROID_COMMANDLINETOOLS_URL && \
  unzip sdk.zip && rm sdk.zip && \
  mv cmdline-tools latest && \
  yes | sdkmanager --licenses && \
  sdkmanager "platform-tools" "platforms;android-34" "sources;android-34" \
  "build-tools;34.0.0" "ndk;${android_ndk_version}"

ARG TARGETPLATFORM
RUN if [ "$TARGETPLATFORM" = "linux/amd64" ]; then \
  sudo npm install -g appium && \
  appium driver install uiautomator2 && \
  sdkmanager "emulator" "system-images;android-34;google_apis_playstore;x86_64" && \
  echo "no" | avdmanager create avd -n Pixel_6_Playstore -k "system-images;android-34;google_apis_playstore;x86_64" -d "pixel_6" ; \
  else \
  echo "Skipping emulator install on $TARGETPLATFORM" ; \
  fi

# Section 8 : Android Studio
ENV STUDIO_PATH=${HOME}/android-studio
ENV PATH=${STUDIO_PATH}/bin:${PATH}
ARG android_studio_version
RUN curl -o /tmp/android-studio.tar.gz -L "https://redirector.gvt1.com/edgedl/android/studio/ide-zips/${android_studio_version}/android-studio-${android_studio_version}-linux.tar.gz" && \
  tar -xzf /tmp/android-studio.tar.gz -C /tmp/ && \
  mv /tmp/android-studio ${STUDIO_PATH} && rm /tmp/android-studio.tar.gz

RUN flutter doctor --android-licenses && flutter doctor

# Section 9 : Bash tweaks
ENV HISTFILE=${HOME}/.bash_history
RUN touch $HISTFILE && echo 'PROMPT_COMMAND="history -a; $PROMPT_COMMAND"' >> ${HOME}/.bashrc

# Section 10 : Entrypoints & scripts
COPY --chown=android:android display-start.sh /usr/local/bin/
COPY --chown=android:android display-start-xpra.sh /usr/local/bin/
COPY --chown=android:android caches-refresh.sh /usr/local/bin/
COPY --chown=android:android entrypoint.sh /usr/local/bin/
COPY --chown=android:android appium-emulator-avd.sh /usr/local/bin/
COPY --chown=android:android android-studio.sh /usr/local/bin/
COPY --chown=android:android emulator-data-load.sh /usr/local/bin/
COPY --chown=android:android openbox-setup.sh /usr/local/bin/

# Rendre les scripts exécutables
RUN chmod +x /usr/local/bin/display-start.sh \
  /usr/local/bin/display-start-xpra.sh \
  /usr/local/bin/caches-refresh.sh \
  /usr/local/bin/entrypoint.sh \
  /usr/local/bin/appium-emulator-avd.sh \
  /usr/local/bin/android-studio.sh \
  /usr/local/bin/emulator-data-load.sh \
  /usr/local/bin/openbox-setup.sh

ARG default_display=20
ENV DISPLAY=:${default_display}

# Section 11 : Application mobile default
# If a current APK is available, it will be automatically launched by 'appium-emulator-avd.sh'.
ARG default_apk_path=/build/output/app.apk
ENV LOCAL_APPLICATION_MOBILE_APK_PATH=${default_apk_path}

ENTRYPOINT ["entrypoint.sh"]
CMD ["studio"]