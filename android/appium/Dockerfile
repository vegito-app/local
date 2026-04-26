FROM builder_image AS builder

USER root

# NodeJS for Appium
RUN --mount=type=cache,id=local-appium-${TARGETPLATFORM}-apt-cache,target=/var/cache/apt,sharing=locked \
    --mount=type=cache,id=local-appium-${TARGETPLATFORM}-apt-lib,target=/var/lib/apt,sharing=locked \
    curl -fsSL https://deb.nodesource.com/setup_20.x | bash - && \
    apt-get install -y nodejs 

ARG non_root_user=android
ARG uid=1000
ARG gid=1000

USER ${non_root_user}

ENV HOME=/home/${non_root_user}
WORKDIR ${HOME}

ENV PATH=${HOME}/node_modules/.bin:${PATH}

RUN --mount=type=cache,id=local-appium-${TARGETPLATFORM}-npm-cache,target=${HOME}/.npm,sharing=locked,uid=${uid},gid=${gid} \
    --mount=type=cache,id=local-appium-${TARGETPLATFORM}-node-gyp,target=${HOME}/.cache/node-gyp,sharing=locked,uid=${uid},gid=${gid} \
    npm install appium@3.0.0-rc.2 && \
    appium driver install uiautomator2

# 📥 Entrypoint to launch emulator + APK
COPY --chown=android:android entrypoint.sh /usr/local/bin/android-appium-entrypoint.sh

RUN chmod +x /usr/local/bin/android-appium-entrypoint.sh

ENTRYPOINT ["android-appium-entrypoint.sh"]