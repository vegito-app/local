ARG android_apk_builder_image=europe-west1-docker.pkg.dev/moov-dev-439608/docker-repository-public/vegito-local:android-flutter-latest
FROM ${android_apk_builder_image}

USER root

# Basic tools
RUN apt-get update && apt-get install -y \
  bash-completion git htop gnupg jq netcat-openbsd \
  rsync socat tree unzip vim wget xz-utils \
  locales net-tools \
  && rm -rf /var/lib/apt/lists/* && dpkg-reconfigure locales

# NodeJS for Appium
RUN curl -fsSL https://deb.nodesource.com/setup_20.x | bash - && \
  apt-get install -y nodejs 

# Google Chrome ou Chromium selon arch
RUN ARCH="$(dpkg --print-architecture)" && \
  if [ "$ARCH" = "amd64" ]; then \
  curl -OL https://dl.google.com/linux/direct/google-chrome-stable_current_amd64.deb && \
  dpkg -i google-chrome-stable_current_amd64.deb && \
  apt-get install -f -y && rm google-chrome-stable_current_amd64.deb ; \
  else \
  apt-get update && apt-get install -y chromium ; \
  fi

# Make /bin/sh point to bash (and not dash)
RUN ln -sf /usr/bin/bash /bin/sh

ARG non_root_user=android
USER ${non_root_user}

ENV HOME=/home/${non_root_user}
WORKDIR ${HOME}

ENV PATH=${HOME}/node_modules/.bin:${PATH}

# Appium
RUN npm install appium@3.0.0-rc.2 && \
  appium driver install uiautomator2

# Android Studio
ENV STUDIO_PATH=${HOME}/android-studio
ENV PATH=${STUDIO_PATH}/bin:${PATH}
ARG android_studio_version
RUN curl -o /tmp/android-studio.tar.gz -L "https://redirector.gvt1.com/edgedl/android/studio/ide-zips/${android_studio_version}/android-studio-${android_studio_version}-linux.tar.gz" && \
  tar -xzf /tmp/android-studio.tar.gz -C /tmp/ && \
  mv /tmp/android-studio ${STUDIO_PATH} && rm /tmp/android-studio.tar.gz

RUN flutter doctor --android-licenses && flutter doctor

# Entrypoints & scripts
COPY --chown=${non_root_user}:${non_root_user} caches-refresh.sh /usr/local/bin/
COPY --chown=${non_root_user}:${non_root_user} android-studio.sh /usr/local/bin/
COPY --chown=${non_root_user}:${non_root_user} entrypoint.sh /usr/local/bin/android-studio-entrypoint.sh

RUN chmod +x \
  /usr/local/bin/caches-refresh.sh \
  /usr/local/bin/android-studio.sh \
  /usr/local/bin/android-studio-entrypoint.sh

ENTRYPOINT ["android-studio-entrypoint.sh"]
CMD ["studio"]