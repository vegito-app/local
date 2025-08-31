ARG android_apk_emulator_image=europe-west1-docker.pkg.dev/moov-dev-439608/docker-repository-public/vegito-local:android-apk-runner-emulator-latest
FROM ${android_apk_emulator_image} AS builder

RUN curl -fsSL https://deb.nodesource.com/setup_18.x | sudo bash - && \
    sudo apt-get install -y nodejs && \
    sudo npm install -g appium@3.0.0-rc.2 && \
    appium driver install uiautomator2