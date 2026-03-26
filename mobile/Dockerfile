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

ARG keystore_alias_name

RUN --mount=type=secret,id=keystore,dst=/tmp/release.keystore.base64 \
    --mount=type=secret,id=keystore_store_pass,dst=/tmp/release.keystore.storepass.base64 \
    export VEGITO_EXAMPLE_APPLICATION_MOBILE_ANDROID_RELEASE_KEYSTORE_PATH=/home/android/android-release.keystore && \
    export VEGITO_EXAMPLE_APPLICATION_MOBILE_ANDROID_RELEASE_KEYSTORE_ALIAS_NAME=${keystore_alias_name} && \
    export VEGITO_EXAMPLE_APPLICATION_MOBILE_ANDROID_RELEASE_KEYSTORE_STORE_PASS_BASE64_PATH=${VEGITO_EXAMPLE_APPLICATION_MOBILE_ANDROID_RELEASE_KEYSTORE_PATH}.storepass.base64 && \
    sudo base64 --decode /tmp/release.keystore.base64 > ${VEGITO_EXAMPLE_APPLICATION_MOBILE_ANDROID_RELEASE_KEYSTORE_PATH} && \
    chmod 600 ${VEGITO_EXAMPLE_APPLICATION_MOBILE_ANDROID_RELEASE_KEYSTORE_PATH} && \
    sudo cat /tmp/release.keystore.storepass.base64 > ${VEGITO_EXAMPLE_APPLICATION_MOBILE_ANDROID_RELEASE_KEYSTORE_STORE_PASS_BASE64_PATH} && \
    export VEGITO_EXAMPLE_APPLICATION_MOBILE_FLUTTER="cd mobile && flutter" && \
    # Build the Flutter application release APK and AAB for distribution
    make example-application-mobile-flutter-android-release && \
    # Build the Flutter application debug APK
    make example-application-mobile-flutter-build-apk-debug && \
    # Extract the SHA1 fingerprint from the provided Android Keystore
    SHA1="$(keytool -list -v \
    -alias ${VEGITO_EXAMPLE_APPLICATION_MOBILE_ANDROID_RELEASE_KEYSTORE_ALIAS_NAME} \
    -keystore ${VEGITO_EXAMPLE_APPLICATION_MOBILE_ANDROID_RELEASE_KEYSTORE_PATH} \
    -storepass "$(base64 --decode ${VEGITO_EXAMPLE_APPLICATION_MOBILE_ANDROID_RELEASE_KEYSTORE_STORE_PASS_BASE64_PATH})" \
    | sed -n 's/.*SHA1: //p' | head -n1)" && \
    test -n "$SHA1" && \
    echo "Local Android Keystore SHA1 fingerprint: $SHA1" && \
    echo -n "$SHA1" > ${VEGITO_EXAMPLE_APPLICATION_MOBILE_ANDROID_RELEASE_KEYSTORE_PATH}.sha1 && \
    rm -f ${VEGITO_EXAMPLE_APPLICATION_MOBILE_ANDROID_RELEASE_KEYSTORE_PATH}

FROM ${apk_runner_appium_image} AS runner

ARG version
ARG environment

COPY --from=builder /home/android/src/mobile/build/app/outputs/flutter-apk/app-release.apk /build/output/app-release-${version}.apk
COPY --from=builder /home/android/src/mobile/build/app/outputs/bundle/release/app-release.aab /build/output/app-release-${version}.aab

COPY --from=builder /home/android/android-release.keystore.sha1  /build/output/app-release-${version}-key.keystore.sha1

COPY --from=builder /home/android/src/mobile/build/app/outputs/flutter-apk/app-debug.apk /build/output/app-debug-${version}.apk

ARG android_package_name

ENV LOCAL_ANDROID_DEBUG_APK_PATH=/build/output/app-debug-${version}.apk
ENV LOCAL_ANDROID_EMULATOR_AVD_ON_START=true
ENV LOCAL_ANDROID_PACKAGE_NAME=${android_package_name}

ENTRYPOINT [ "android-appium-entrypoint.sh" ]
