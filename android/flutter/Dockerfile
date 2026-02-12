ARG debian_image=debian:latest
ARG android_apk_emulator_image=vegito-local/vegito-local:android-apk-emulator-latest

FROM ${debian_image}
FROM ${android_apk_emulator_image} AS apk-builder

USER root

# Adding Android build tools
# clang, cmake, ninja-build : for native build (NDK)
# openjdk-17-jdk : for Android tools (sdkmanager, avdmanager, etc.)
# make, git, unzip, wget, curl, zip : miscellaneous utilities
RUN apt-get update && apt-get install -y \
    clang cmake ninja-build openjdk-17-jdk \
    make git unzip wget curl zip && rm -rf /var/lib/apt/lists/*

# Use non-root user to install Flutter and Android SDK
ARG non_root_user=android
USER ${non_root_user}

# Flutter SDK
ARG flutter_version
ENV FLUTTER_HOME=/home/${non_root_user}/flutter
ENV PATH="${PATH}:${FLUTTER_HOME}/bin"
# tar -xf ~/Downloads/flutter_linux_${flutter_version}-stable.tar.xz -C ~/home/${non_root_user}
RUN git clone -b stable https://github.com/flutter/flutter.git $FLUTTER_HOME && \
    cd $FLUTTER_HOME && \
    git checkout $flutter_version && \
    flutter config --no-analytics && \
    flutter precache && \
    flutter doctor

# Android SDK complete (NDK + build-tools)
ENV ANDROID_SDK=${HOME}/Android/Sdk
ENV PATH=${PATH}:${ANDROID_SDK}/cmdline-tools/latest/bin:${ANDROID_SDK}/platform-tools:${ANDROID_SDK}/build-tools/34.0.0
ARG android_ndk_version
RUN sdkmanager \
    "build-tools;34.0.0" \
    "platforms;android-34" \
    "platforms;android-36" \
    "ndk;${android_ndk_version}"
