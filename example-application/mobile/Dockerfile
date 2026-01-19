ARG apk_runner_appium_image=europe-west1-docker.pkg.dev/moov-dev-439608/docker-repository-public/vegito-local:android-appium-latest
ARG apk_builder_image=europe-west1-docker.pkg.dev/moov-dev-439608/docker-repository-public/vegito-local:android-flutter-latest
FROM ${apk_builder_image} AS builder

ARG non_root_user=android
ARG builder_home=/home/${non_root_user}

USER ${non_root_user}

ENV HOME=${builder_home}

RUN mkdir ${HOME}/src \
    ${HOME}/src/mobile \
    ${HOME}/src/mobile/android \
    ${HOME}/src/local \
    ${HOME}/src/local/android

WORKDIR ${HOME}/src 

COPY --from=approot Makefile .
COPY --from=approot local/local.mk local/
COPY --from=approot local/android/android.mk local/android/
COPY --from=approot git.mk .

COPY --from=approot example-application.mk .

COPY --chown=${non_root_user}:${non_root_user} pubspec.yaml mobile/
COPY --chown=${non_root_user}:${non_root_user} pubspec.lock mobile/
COPY --chown=${non_root_user}:${non_root_user} mobile.mk mobile/
COPY --chown=${non_root_user}:${non_root_user} android mobile/android/
COPY --chown=${non_root_user}:${non_root_user} lib mobile/lib/

COPY --from=android android.mk android/

# Build APK and AAB signed release with the provided keystore and keystore password
# The keystore file and the keystore password must be provided as build secrets
# Example:
#   --secret id=keystore,src=path/to/keystore/file
#   --secret id=keystore_store_pass,src=path/to/keystore/password
# See https://docs.docker.com/engine/reference/commandline/buildx_build/#setting-secrets
# and https://docs.docker.com/engine/reference/commandline/buildx_build/#use-mount
ENV VEGITO_EXAMPLE_APPLICATION_MOBILE_ANDROID_RELEASE_KEYSTORE_PATH=/home/android/.android/release.keystore
# Prepare empty keystore files with correct permissions. They will be populated in the next step.
RUN mkdir -p /home/android/.android && \
    touch ${VEGITO_EXAMPLE_APPLICATION_MOBILE_ANDROID_RELEASE_KEYSTORE_PATH} && \
    chmod 600 ${VEGITO_EXAMPLE_APPLICATION_MOBILE_ANDROID_RELEASE_KEYSTORE_PATH} && \
    touch ${VEGITO_EXAMPLE_APPLICATION_MOBILE_ANDROID_RELEASE_KEYSTORE_PATH}.storepass.base64 && \
    chmod 600 ${VEGITO_EXAMPLE_APPLICATION_MOBILE_ANDROID_RELEASE_KEYSTORE_PATH}.storepass.base64 && \
    touch ${VEGITO_EXAMPLE_APPLICATION_MOBILE_ANDROID_RELEASE_KEYSTORE_PATH}.sha1 && \
    chmod 600 ${VEGITO_EXAMPLE_APPLICATION_MOBILE_ANDROID_RELEASE_KEYSTORE_PATH}.sha1

RUN --mount=type=secret,id=keystore,dst=/tmp/release.keystore \
    --mount=type=secret,id=keystore_store_pass,dst=/tmp/release.storepass \
    sudo cat /tmp/release.keystore | base64 --decode > ${VEGITO_EXAMPLE_APPLICATION_MOBILE_ANDROID_RELEASE_KEYSTORE_PATH} && \
    sudo cat /tmp/release.storepass > ${VEGITO_EXAMPLE_APPLICATION_MOBILE_ANDROID_RELEASE_KEYSTORE_PATH}.storepass.base64 && \
    SHA1=$(keytool -list -v \
    -keystore ${VEGITO_EXAMPLE_APPLICATION_MOBILE_ANDROID_RELEASE_KEYSTORE_PATH} \
    -storepass $(cat ${VEGITO_EXAMPLE_APPLICATION_MOBILE_ANDROID_RELEASE_KEYSTORE_PATH}.storepass.base64 | base64 --decode) \
    | grep 'SHA1:' | awk '{print $2}') && \
    echo "Local Android Keystore SHA1 fingerprint: $SHA1" && \
    echo -n "$SHA1" > ${VEGITO_EXAMPLE_APPLICATION_MOBILE_ANDROID_RELEASE_KEYSTORE_PATH}.sha1 && \
    mv ${VEGITO_EXAMPLE_APPLICATION_MOBILE_ANDROID_RELEASE_KEYSTORE_PATH}.sha1 /home/android/src/local/android/app-release.keystore.sha1

ARG version=dev
ARG keystore_alias_name=vegito-local-release

RUN \
    LOCAL_ANDROID_APKSIGNER=apksigner \
    LOCAL_ANDROID_JARSIGNER=jarsigner \
    LOCAL_ANDROID_RELEASE_AAB_PATH=/home/android/src/mobile/build/app/outputs/bundle/release/app-release.aab \
    LOCAL_ANDROID_RELEASE_APK_SIGNED_ALIGNED_PATH=/home/android/src/local/android/app-release-${version}-signed-aligned.apk \
    LOCAL_ANDROID_RELEASE_KEYSTORE_ALIAS_NAME=${keystore_alias_name} \
    LOCAL_ANDROID_ZIPALIGN=zipalign \
    LOCAL_EXAMPLE_APPLICATION_FLUTTER="cd mobile && flutter" \
    VEGITO_EXAMPLE_APPLICATION_MOBILE_IMAGE_APK_RELEASE_PATH=/home/android/src/mobile/build/app/outputs/flutter-apk/app-release.apk \
    make \
    example-application-mobile-android-release

RUN \
    LOCAL_ANDROID_RELEASE_AAB_PATH=/home/android/src/mobile/build/app/outputs/bundle/release/app-release.aab \
    LOCAL_ANDROID_RELEASE_APK_SIGNED_ALIGNED_PATH=/home/android/src/local/android/app-release-${version}-signed-aligned.apk \
    LOCAL_ANDROID_RELEASE_KEYSTORE_ALIAS_NAME=${keystore_alias_name} \
    LOCAL_EXAMPLE_APPLICATION_FLUTTER="cd mobile && flutter" \
    VEGITO_EXAMPLE_APPLICATION_MOBILE_IMAGE_APK_RELEASE_PATH=/home/android/src/mobile/build/app/outputs/flutter-apk/app-release.apk \
    make \
    example-application-mobile-flutter-build-apk-debug

FROM ${apk_runner_appium_image} AS runner

ARG version=dev

COPY --from=builder /home/android/src/local/android/app-release-${version}-signed-aligned.apk /build/output/app-release-${version}.apk
COPY --from=builder /home/android/src/local/android/app-release-${version}-signed.aab /build/output/app-release-${version}.aab

COPY --from=builder /home/android/src/local/android/app-release.keystore.sha1  /build/output/app-release-${version}-key.keystore.sha1

COPY --from=builder /home/android/src/mobile/build/app/outputs/flutter-apk/app-debug.apk /build/output/app-debug-${version}.apk

ARG android_package_name=dev.vegito.app.android

ENV LOCAL_ANDROID_DEBUG_APK_PATH=/build/output/app-debug-${version}.apk
ENV LOCAL_ANDROID_APPIUM_EMULATOR_AVD_ON_START=true
ENV LOCAL_ANDROID_PACKAGE_NAME=${android_package_name}

ENTRYPOINT [ "android-appium-entrypoint.sh" ]
