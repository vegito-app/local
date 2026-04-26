FROM flutter
USER root

# Make /bin/sh point to bash (and not dash)
RUN ln -sf /usr/bin/bash /bin/sh

# NodeJS for Appium
RUN curl -fsSL https://deb.nodesource.com/setup_20.x | bash - && \
  apt-get install -y nodejs 

# Google Chrome ou Chromium selon arch
RUN --mount=type=cache,id=local-android-studio-${TARGETPLATFORM}-apt-cache,target=/var/cache/apt,sharing=locked \
  --mount=type=cache,id=local-android-studio-${TARGETPLATFORM}-apt-lib,target=/var/lib/apt,sharing=locked \
  ARCH="$(dpkg --print-architecture)" && \
  if [ "$ARCH" = "amd64" ]; then \
  curl -OL https://dl.google.com/linux/direct/google-chrome-stable_current_amd64.deb && \
  dpkg -i google-chrome-stable_current_amd64.deb && \
  apt-get install -f -y && rm google-chrome-stable_current_amd64.deb ; \
  else \
  apt-get -o Acquire::Retries=3 update && apt-get install -y chromium ; \
  fi

# Make /bin/sh point to bash (and not dash)
RUN ln -sf /usr/bin/bash /bin/sh

# Install nvidia tools for monitoring GPU usage in Android Studio
RUN --mount=type=cache,id=local-android-studio-${TARGETPLATFORM}-apt-cache,target=/var/cache/apt,sharing=locked \
  --mount=type=cache,id=local-android-studio-${TARGETPLATFORM}-apt-lib,target=/var/lib/apt,sharing=locked \
  apt-get -o Acquire::Retries=3 update && apt-get install -y nvtop pipx \
  && pipx ensurepath \
  && pipx install nvitop

RUN apt-get -o Acquire::Retries=3 update && apt-get install -y locales \
  && rm -rf /var/lib/apt/lists/* && \
  dpkg-reconfigure locales && \
  locale-gen en_US.UTF-8 

ENV LANG=en_US.UTF-8

ARG non_root_user=android
USER ${non_root_user}

ENV HOME=/home/${non_root_user}
WORKDIR ${HOME}

ENV PATH=${HOME}/node_modules/.bin:${PATH}

RUN npm install appium@3.0.0-rc.2 && \
  appium driver install uiautomator2

# Android Studio
ENV STUDIO_PATH=${HOME}/android-studio
ENV PATH=${STUDIO_PATH}/bin:${PATH}
ARG android_studio_version
# RUN curl -o /tmp/android-studio.tar.gz -L "https://redirector.gvt1.com/edgedl/android/studio/ide-zips/${android_studio_version}/android-studio-${android_studio_version}-linux.tar.gz" && \
RUN curl -o /tmp/android-studio.tar.gz -L https://edgedl.me.gvt1.com/android/studio/ide-zips/${android_studio_version}-linux.tar.gz && \
  tar -xzf /tmp/android-studio.tar.gz -C /tmp/ && \
  mv /tmp/android-studio ${STUDIO_PATH} && rm /tmp/android-studio.tar.gz

RUN flutter doctor --android-licenses && flutter doctor

# 📥 Use Appium entrypoint to launch emulator + APK
COPY --from=appium --chown=${non_root_user}:${non_root_user}  entrypoint.sh /usr/local/bin/android-appium-entrypoint.sh

# Entrypoints & scripts
COPY --chown=${non_root_user}:${non_root_user} caches-refresh.sh /usr/local/bin/
COPY --chown=${non_root_user}:${non_root_user} android-studio.sh /usr/local/bin/
COPY --chown=${non_root_user}:${non_root_user} entrypoint.sh /usr/local/bin/android-studio-entrypoint.sh

RUN chmod +x \
  /usr/local/bin/android-appium-entrypoint.sh \
  /usr/local/bin/caches-refresh.sh \
  /usr/local/bin/android-studio.sh \
  /usr/local/bin/android-studio-entrypoint.sh

ENTRYPOINT ["android-studio-entrypoint.sh"]
CMD ["studio"]

