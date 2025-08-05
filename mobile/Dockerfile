ARG android_studio_image=europe-west1-docker.pkg.dev/moov-dev-439608/docker-repository-public/vegito-local:android-studio-latest
FROM ${android_studio_image} AS builder

USER android

ENV HOME=/home/android

WORKDIR ${HOME}

RUN mkdir -p ${HOME}/app/mobile ${HOME}/app/infra

WORKDIR ${HOME}/app

COPY --chown=android:android mobile mobile/
COPY --chown=android:android Makefile .
COPY --chown=android:android application.mk .
COPY --chown=android:android git.mk .
COPY --chown=android:android infra/infra.mk infra/
# COPY --chown=android:android mobile/scripts/build_apk.sh .
# RUN chmod +x build_apk.sh

ARG environment
ENV INFRA_ENV=${environment}

RUN cd mobile && ./build_apk.sh

FROM ${android_studio_image} AS android_studio

ARG environment
ENV INFRA_ENV=${environment}

COPY --from=builder /home/android/app/mobile/build/app/outputs/flutter-apk/app-${environment}-release.apk /build/output/app.apk

ARG apk_path=/build/output/app.apk
ENV LOCAL_APPLICATION_MOBILE_APK_PATH=${apk_path}

ENV LOCAL_APPLICATION_MOBILE_ANDROID_PACKAGE_NAME=${environment}.vegito.app.android

# Démarrage automatique du système
# COPY mobile/entrypoint.sh /usr/local/bin/application-mobile-entrypoint.sh

# ENTRYPOINT ["/usr/local/bin/application-mobile-entrypoint.sh"]