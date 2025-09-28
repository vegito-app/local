ARG android_apk_emulator_image=europe-west1-docker.pkg.dev/moov-dev-439608/docker-repository-public/vegito-local:android-apk-runner-emulator-latest
FROM ${android_apk_emulator_image} AS builder

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

# 📥 Entrypoint pour lancer émulateur + APK
COPY --chown=android:android entrypoint.sh /usr/local/bin/android-appium-entrypoint.sh

# Rendre les scripts exécutables
RUN chmod +x /usr/local/bin/android-appium-entrypoint.sh

ENTRYPOINT ["android-appium-entrypoint.sh"]