ARG local_dev_only_docker_registry_public=europe-west1-docker.pkg.dev/moov-dev-439608/docker-repository-public

FROM ${local_dev_only_docker_registry_public}/vegito-local:android-emulator-latest AS builder

USER root

# NodeJS for Appium
RUN curl -fsSL https://deb.nodesource.com/setup_20.x | bash - && \
    apt-get install -y nodejs 

ARG non_root_user=android
USER ${non_root_user}

ENV HOME=/home/${non_root_user}
WORKDIR ${HOME}

ENV PATH=${HOME}/node_modules/.bin:${PATH}

RUN npm install appium@3.0.0-rc.2 \
    appium driver install uiautomator2

# 📥 Entrypoint to launch emulator + APK
COPY --chown=android:android entrypoint.sh /usr/local/bin/android-appium-entrypoint.sh

RUN chmod +x /usr/local/bin/android-appium-entrypoint.sh

ENTRYPOINT ["android-appium-entrypoint.sh"]