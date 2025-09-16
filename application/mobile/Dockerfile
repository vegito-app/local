ARG apk_runner_appium_image=europe-west1-docker.pkg.dev/moov-dev-439608/docker-repository-public/vegito-local:android-appium-latest
ARG apk_builder_image=europe-west1-docker.pkg.dev/moov-dev-439608/docker-repository-public/vegito-local:android-flutter-latest
FROM ${apk_builder_image} AS builder

ARG non_root_user=android
ARG builder_home=/home/${non_root_user}

USER ${non_root_user}

ENV HOME=${builder_home}

RUN mkdir -p ${HOME}/src/application/mobile \
    ${HOME}/src/android

WORKDIR ${HOME}/src

COPY --from=project Makefile .
COPY --from=project local.mk .
COPY --from=project git.mk .

COPY --from=approot application.mk application/

COPY --chown=${non_root_user}:${non_root_user} pubspec.yaml application/mobile/
COPY --chown=${non_root_user}:${non_root_user} pubspec.lock application/mobile/
COPY --chown=${non_root_user}:${non_root_user} mobile.mk application/mobile/
COPY --chown=${non_root_user}:${non_root_user} android application/mobile/android/
COPY --chown=${non_root_user}:${non_root_user} lib application/mobile/lib/

ARG version=dev

COPY --from=android android.mk android/

ARG keystore_alias_name=vegito-local-release

RUN --mount=type=secret,id=keystore,dst=/tmp/release.keystore \
    --mount=type=secret,id=keystore_store_pass,dst=/tmp/.storepass \
    export LOCAL_APPLICATION_MOBILE_ANDROID_RELEASE_KEYSTORE_PATH=/home/android/.android/release.keystore && \
    sudo cat /tmp/release.keystore | base64 --decode > ${LOCAL_APPLICATION_MOBILE_ANDROID_RELEASE_KEYSTORE_PATH} && \
    export LOCAL_APPLICATION_MOBILE_ANDROID_RELEASE_KEYSTORE_STORE_PASS=$(sudo cat /tmp/.storepass|base64 --decode) && \
    LOCAL_ANDROID_CONTAINER_EXEC="" \
    LOCAL_ANDROID_RELEASE_KEYSTORE_ALIAS_NAME=${keystore_alias_name} \
    LOCAL_ANDROID_RELEASE_AAB_PATH=/home/android/src/application/mobile/build/app/outputs/bundle/release/app-release.aab \
    LOCAL_APPLICATION_MOBILE_IMAGE_APK_RELEASE_PATH=/home/android/src/application/mobile/build/app/outputs/flutter-apk/app-release.apk \
    LOCAL_ANDROID_RELEASE_APK_SIGNED_ALIGNED_PATH=/home/android/src/android/app-release-${version}-signed-aligned.apk \
    FLUTTER="cd application/mobile && flutter" \
    VERSION=${version} \
    make \
    local-application-mobile-flutter-android-release \
    local-android-sign-apk \
    local-android-verify-apk \
    local-android-align-apk \
    local-android-sign-aab

FROM ${apk_runner_appium_image} AS runner

ARG version=dev

COPY --from=builder /home/android/src/application/mobile/app-release-${version}-signed-aligned.apk /build/output/app-release-${version}.apk
COPY --from=builder /home/android/src/application/mobile/app-release-signed-${version}.aab /build/output/app-release-${version}.aab

ARG android_package_name=dev.vegito.app.android

ENV LOCAL_ANDROID_PACKAGE_NAME=${android_package_name}
ENV LOCAL_ANDROID_APPIUM_EMULATOR_AVD_ON_START=true

ENTRYPOINT [ "android-appium-entrypoint.sh" ]