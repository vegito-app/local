FROM android_emulator

USER root

ARG non_root_user=android-appium
ARG uid=1000
ARG gid=1000

# 👤 Rename non root user
RUN usermod -l ${non_root_user} android-emulator \
    && groupmod -n ${non_root_user} android-emulator \
    && \
    echo "${non_root_user}:${non_root_user}" | chpasswd && \
    adduser ${non_root_user} sudo && \
    echo "${non_root_user} ALL=(ALL) NOPASSWD:ALL" > /etc/sudoers.d/${non_root_user} && \
    chmod 0440 /etc/sudoers.d/${non_root_user}

ENV USER=${non_root_user}

# NodeJS for Appium
RUN --mount=type=cache,id=local-appium-${TARGETPLATFORM}-apt-cache,target=/var/cache/apt,sharing=locked \
    --mount=type=cache,id=local-appium-${TARGETPLATFORM}-apt-lib,target=/var/lib/apt,sharing=locked \
    curl -fsSL https://deb.nodesource.com/setup_20.x | bash - && \
    apt-get install -y nodejs 

ENV PATH=${HOME}/node_modules/.bin:${PATH}

USER ${non_root_user}

WORKDIR ${HOME}

RUN --mount=type=cache,id=local-appium-${TARGETPLATFORM}-npm-cache,target=${HOME}/.npm,sharing=locked,uid=${uid},gid=${gid} \
    --mount=type=cache,id=local-appium-${TARGETPLATFORM}-node-gyp,target=${HOME}/.cache/node-gyp,sharing=locked,uid=${uid},gid=${gid} \
    npm install appium@3.0.0-rc.2 && \
    appium driver install uiautomator2

# 📥 Entrypoint to launch emulator + APK
COPY --chown=${uid}:${gid} entrypoint.sh /usr/local/bin/android-appium-entrypoint.sh
COPY --chown=${uid}:${gid} appium-start.sh /usr/local/bin/android-appium-start.sh

RUN chmod +x /usr/local/bin/android-appium-entrypoint.sh
RUN chmod +x /usr/local/bin/android-appium-start.sh

ENTRYPOINT ["android-appium-entrypoint.sh"]
CMD [ "android-appium-start.sh" ]