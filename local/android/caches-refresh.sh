#!/bin/bash

set -eu

# Android emulators cache
ANDROID_AVD=${HOME}/.android/avd
rm -rf $ANDROID_AVD
mkdir -p ${PWD}/local/android/studio/avd
ln -sf ${PWD}/local/android/studio/avd $ANDROID_AVD

# Android Studio config
ANDROID_STUDIO_CONFIG=${HOME}/.config/Google
rm -rf $ANDROID_STUDIO_CONFIG
mkdir -p ${PWD}/local/android/studio/config
ln -sf ${PWD}/local/android/studio/config $ANDROID_STUDIO_CONFIG
# Drop lock eventually remaining after previous container run exit
rm -f ${ANDROID_STUDIO_CONFIG}/AndroidStudio2024.1/.lock

# Android Studio config (local)
ANDROID_STUDIO_LOCAL_SHARE_CONFIG=${HOME}/.local/share/Google
rm -rf $ANDROID_STUDIO_LOCAL_SHARE_CONFIG
mkdir -p ${PWD}/local/android/studio/localconfig ${HOME}/.local/share
ln -sf ${PWD}/local/android/studio/localconfig $ANDROID_STUDIO_LOCAL_SHARE_CONFIG
