ARG android_apk_builder_image=europe-west1-docker.pkg.dev/moov-dev-439608/docker-repository-public/vegito-local:android-flutter-latest
FROM ${android_apk_builder_image}

USER root

# Section 1 : Dépendances système
RUN apt-get update && apt-get install -y \
  bash-completion git htop gnupg jq netcat-openbsd \
  make rsync socat sudo tree unzip vim wget xz-utils \
  menu-xdg net-tools xpra \
  clang cmake ninja-build openjdk-17-jdk libgtk-3-dev \
  locales \
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

RUN ln -sf /usr/bin/bash /bin/sh
ARG non_root_user=android
USER ${non_root_user}
ENV HOME=/home/${non_root_user}
WORKDIR ${HOME}

USER root
RUN curl -fsSL https://deb.nodesource.com/setup_18.x | bash - && \
  apt-get install -y nodejs && \
  npm install -g appium@3.0.0-rc.2 && \
  appium driver install uiautomator2

USER ${non_root_user}

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
COPY --chown=${non_root_user}:${non_root_user} display-start.sh /usr/local/bin/
COPY --chown=${non_root_user}:${non_root_user} display-start-xpra.sh /usr/local/bin/
COPY --chown=${non_root_user}:${non_root_user} studio/caches-refresh.sh /usr/local/bin/
COPY --chown=${non_root_user}:${non_root_user} studio/entrypoint.sh /usr/local/bin/
COPY --chown=${non_root_user}:${non_root_user} appium-emulator-avd.sh /usr/local/bin/
COPY --chown=${non_root_user}:${non_root_user} android-studio.sh /usr/local/bin/
COPY --chown=${non_root_user}:${non_root_user} emulator-data-load.sh /usr/local/bin/
COPY --chown=${non_root_user}:${non_root_user} openbox-setup.sh /usr/local/bin/

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
ENV APPLICATION_MOBILE_APK_PATH=${default_apk_path}

ENTRYPOINT ["entrypoint.sh"]
CMD ["studio"]