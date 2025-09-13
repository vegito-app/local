ARG android_apk_emulator_image=europe-west1-docker.pkg.dev/moov-dev-439608/docker-repository-public/vegito-local:android-apk-runner-emulator-latest
FROM ${android_apk_emulator_image} AS builder

USER root

RUN curl -fsSL https://deb.nodesource.com/setup_20.x | bash - && \
    apt-get install -y nodejs && \
    npm install -g appium@3.0.0-rc.2 \
    appium driver install uiautomator2

ARG non_root_user=android
USER ${non_root_user}

# 📥 Entrypoint pour lancer émulateur + APK
COPY --chown=android:android appium-emulator-avd.sh /usr/local/bin/
COPY --chown=android:android entrypoint.sh /usr/local/bin/android-appium-entrypoint.sh

# Rendre les scripts exécutables
RUN chmod +x \
    /usr/local/bin/appium-emulator-avd.sh \
    /usr/local/bin/android-appium-entrypoint.sh

# 📱 Par défaut, on peut passer un APK déjà monté dans /apk/app.apk
ARG default_apk_path=/apk/app.apk
ENV APK_PATH=${default_apk_path}
ENV LOCAL_ANDROID_APPIUM_EMULATOR_AVD_ON_START=true
ENV LOCAL_APPLICATION_TESTS_MOBILE_IMAGES_DIR=tests/mobile_images

ENTRYPOINT ["android-appium-entrypoint.sh"]