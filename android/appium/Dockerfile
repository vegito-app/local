ARG android_apk_emulator_image=europe-west1-docker.pkg.dev/moov-dev-439608/docker-repository-public/vegito-local:android-apk-runner-emulator-latest
FROM ${android_apk_emulator_image} AS builder

USER root

RUN curl -fsSL https://deb.nodesource.com/setup_18.x | bash - && \
    apt-get install -y nodejs && \
    npm install -g appium@3.0.0-rc.2 \
    appium driver install uiautomator2

ARG non_root_user=android
USER ${non_root_user}
