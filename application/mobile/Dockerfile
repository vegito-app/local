ARG android_studio_image=europe-west1-docker.pkg.dev/moov-dev-439608/docker-repository-public/vegito-local:android-studio-latest
FROM ${android_studio_image} AS builder

USER android

ENV HOME=/home/android

WORKDIR ${HOME}

RUN mkdir -p ${HOME}/app/mobile ${HOME}/app/infra

WORKDIR ${HOME}/app

COPY --chown=android:android mobile mobile/

RUN cd mobile && flutter build apk --release

FROM ${android_studio_image} AS android_studio

COPY --from=builder /home/android/app/mobile/build/app/outputs/flutter-apk/app-release.apk /build/output/app.apk

ARG android_package_name=dev.vegito.app.android
ENV LOCAL_APPLICATION_MOBILE_ANDROID_PACKAGE_NAME=${android_package_name}