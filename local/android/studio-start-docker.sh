#!/bin/sh

set -eu

trap "echo Exited with code $?." EXIT

# Android SDK
ANDROID_SDK=${HOME}/Android/Sdk
rm -rf $ANDROID_SDK
mkdir -p ${PWD}/local/android/studio/Sdk
mkdir -p `dirname ${ANDROID_SDK}`
ln -sf ${PWD}/local/android/studio/Sdk $ANDROID_SDK

# Android Cache
ANDROID_CACHE=${HOME}/.android
rm -rf $ANDROID_CACHE
mkdir -p ${PWD}/local/android/studio/cache
ln -sf ${PWD}/local/android/studio/cache $ANDROID_CACHE


# Lancez xvfb en arrière-plan
Xvfb ${DISPLAY} -nolisten tcp -cc 4 -screen 0, 1440x900x24 &

# Boucle d'attente pour permettre à xvfb de démarrer
while ! xdpyinfo -display ${DISPLAY} > /dev/null 2>&1; do sleep 1; done

x11vnc -display ${DISPLAY} -nopw -forever &

# Lancez Android Studio
${STUDIO_PATH}/bin/studio.sh
