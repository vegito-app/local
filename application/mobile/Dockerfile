ARG apk_runner_appium_image=europe-west1-docker.pkg.dev/moov-dev-439608/docker-repository-public/vegito-local:android-appium-latest
ARG apk_builder_image=europe-west1-docker.pkg.dev/moov-dev-439608/docker-repository-public/vegito-local:android-flutter-latest
FROM ${apk_builder_image} AS builder

ARG non_root_user=android
ARG builder_home=/home/${non_root_user}

USER ${non_root_user}

ENV HOME=${builder_home}

RUN mkdir -p ${HOME}/src/application/mobile ${HOME}/src/application/infra

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

RUN FLUTTER="cd application/mobile && flutter" make \
    local-application-mobile-flutter-pub-get \
    local-application-mobile-flutter-build-apk-release \
    local-application-mobile-flutter-build-appbundle-release

FROM ${apk_runner_appium_image} AS runner

ENV LOCAL_ANDROID_APK_PATH=/build/output/app-release.apk
ENV LOCAL_ANDROID_AAB_PATH=/build/output/app-release.aab

COPY --from=builder /home/android/src/application/mobile/build/app/outputs/flutter-apk/app-release.apk ${LOCAL_ANDROID_APK_PATH}
COPY --from=builder /home/android/src/application/mobile/build/app/outputs/bundle/release/app-release.aab ${LOCAL_ANDROID_AAB_PATH}

ARG android_package_name=dev.vegito.app.android

ENV LOCAL_ANDROID_PACKAGE_NAME=${android_package_name}

ENV LOCAL_ANDROID_APPIUM_EMULATOR_AVD_ON_START=true

ENTRYPOINT [ "android-appium-entrypoint.sh" ]