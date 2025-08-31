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

RUN cd application/mobile && flutter build apk --release

FROM ${apk_runner_appium_image} AS android_studio

COPY --from=builder /home/android/src/application/mobile/build/app/outputs/flutter-apk/app-release.apk /build/output/app.apk

ARG android_package_name=dev.vegito.app.android
ENV APPLICATION_MOBILE_ANDROID_PACKAGE_NAME=${android_package_name}