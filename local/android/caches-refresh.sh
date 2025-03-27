#!/bin/bash

set -eu

LOCAL_ANDROID_STUDIO=${PWD}/local/android/studio
mkdir -p $LOCAL_ANDROID_STUDIO

# # Android emulators cache
# ANDROID_AVD=${HOME}/.android/avd
# mkdir -p ${PWD}/local/android/studio/avd
# ln -sf ${PWD}/local/android/studio/avd $ANDROID_AVD

# # Android Studio config
ANDROID_STUDIO_CONFIG=${HOME}/.config/Google
mkdir -p $LOCAL_ANDROID_STUDIO/Google
ln -s $LOCAL_ANDROID_STUDIO/Google $ANDROID_STUDIO_CONFIG

# Drop lock eventually remaining after previous container run exit
rm -f ${ANDROID_STUDIO_CONFIG}/AndroidStudio2024.1/.lock

# # Android Studio config (local)
ANDROID_STUDIO_LOCAL_SHARE_CONFIG=${HOME}/.local/share/Google
mkdir -p $LOCAL_ANDROID_STUDIO/localconfig ${HOME}/.local/share
ln -s $LOCAL_ANDROID_STUDIO/localconfig $ANDROID_STUDIO_LOCAL_SHARE_CONFIG

# Android Studio Gradle config
ANDROID_STUDIO_GRADLE_CONFIG=${HOME}/.gradle
mkdir -p $LOCAL_ANDROID_STUDIO/gradle
ln -s $LOCAL_ANDROID_STUDIO/gradle $ANDROID_STUDIO_GRADLE_CONFIG

# Android Studio Java cache
ANDROID_STUDIO_JAVA_CONFIG=${HOME}/.java
mkdir -p $LOCAL_ANDROID_STUDIO/java
ln -s $LOCAL_ANDROID_STUDIO/java $ANDROID_STUDIO_JAVA_CONFIG

# Android Studio Flutter config
ANDROID_STUDIO_FLUTTER_CONFIG=${HOME}/flutter
rsync -av $ANDROID_STUDIO_FLUTTER_CONFIG $LOCAL_ANDROID_STUDIO
rm -rf $ANDROID_STUDIO_FLUTTER_CONFIG
ln -s $LOCAL_ANDROID_STUDIO/flutter $ANDROID_STUDIO_FLUTTER_CONFIG

# Android Studio Dart config
ANDROID_STUDIO_FLUTTER_CONFIG=${HOME}/.dart-tool
rsync -av $ANDROID_STUDIO_FLUTTER_CONFIG $LOCAL_ANDROID_STUDIO
rm -rf $ANDROID_STUDIO_FLUTTER_CONFIG
ln -s $LOCAL_ANDROID_STUDIO/.dart-tool $ANDROID_STUDIO_FLUTTER_CONFIG

# Android Studio Pub config
ANDROID_STUDIO_PUB_CACHE_CONFIG=${HOME}/.pub-cache
rsync -av $ANDROID_STUDIO_PUB_CACHE_CONFIG $LOCAL_ANDROID_STUDIO
rm -rf $ANDROID_STUDIO_PUB_CACHE_CONFIG
ln -s $LOCAL_ANDROID_STUDIO/.pub-cache $ANDROID_STUDIO_PUB_CACHE_CONFIG

# Android Studio SDK
ANDROID_STUDIO_HOME=${HOME}/Android
rsync -av $ANDROID_STUDIO_HOME $LOCAL_ANDROID_STUDIO
rm -rf $ANDROID_STUDIO_HOME && \
ln -s $LOCAL_ANDROID_STUDIO/Android $ANDROID_STUDIO_HOME

# Android Studio Cache
ANDROID_STUDIO_CACHE=${HOME}/.android
rsync -av $ANDROID_STUDIO_CACHE $LOCAL_ANDROID_STUDIO
rm -rf $ANDROID_STUDIO_CACHE && \
ln -s $LOCAL_ANDROID_STUDIO/.android $ANDROID_STUDIO_CACHE

# # Android Studio Editor
# ANDROID_STUDIO_EDITOR=${HOME}/android-studio
# rsync -av $ANDROID_STUDIO_EDITOR $LOCAL_ANDROID_STUDIO
# rm -rf $ANDROID_STUDIO_EDITOR && \
# ln -s $LOCAL_ANDROID_STUDIO/android-studio $ANDROID_STUDIO_EDITOR

# # Android Studio Google Chrome
# ANDROID_STUDIO_GOOGLE_CHROME=${HOME}/.config/google-chrome
# mkdir -p $LOCAL_ANDROID_STUDIO/google-chrome
# rm -rf $ANDROID_STUDIO_GOOGLE_CHROME && \
# ln -s $LOCAL_ANDROID_STUDIO/google-chrome $ANDROID_STUDIO_GOOGLE_CHROME
