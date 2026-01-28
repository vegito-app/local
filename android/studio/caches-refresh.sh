#!/bin/sh

set -uo pipefail


caches_refresh_success=false
# 🧹 Function called at the end of the script to check for success
check_success() {
    if [ $caches_refresh_success = true ]; then
        echo "♻️ Android Studio caches refreshed successfully."
    else
        echo "❌ Android Studio caches refresh failed."
    fi
}

# 🚨 Register cleanup function to run on script exit
trap check_success EXIT

local_container_cache=${LOCAL_ANDROID_STUDIO_CONTAINER_CACHE:-${LOCAL_DIR:-${PWD}}/.containers/android-studio}
mkdir -p $local_container_cache

# Android Studio config
ANDROID_STUDIO_CONFIG=${HOME}/.config/Google
mkdir -p ${local_container_cache}/Google ${HOME}/.config
rm -rf $ANDROID_STUDIO_CONFIG
ln -sf ${local_container_cache}/Google $ANDROID_STUDIO_CONFIG

# Drop lock eventually remaining after previous container run exit
rm -f ${ANDROID_STUDIO_CONFIG}/AndroidStudio2024.1/.lock

# # Android Studio config
ANDROID_STUDIO_CACHE=${HOME}/.cache/Google
mkdir -p ${local_container_cache}/.cache/Google ${HOME}/.cache
rm -rf $ANDROID_STUDIO_CACHE
ln -sf ${local_container_cache}/.cache/Google $ANDROID_STUDIO_CACHE

# # Android Studio config (local)
ANDROID_STUDIO_LOCAL_SHARE_CONFIG=${HOME}/.share/Google
mkdir -p ${local_container_cache}/localconfig ${HOME}/.share
rm -rf $ANDROID_STUDIO_LOCAL_SHARE_CONFIG
ln -sf ${local_container_cache}/localconfig $ANDROID_STUDIO_LOCAL_SHARE_CONFIG

# Android Studio Gradle config
ANDROID_STUDIO_GRADLE_CONFIG=${HOME}/.gradle
mkdir -p ${local_container_cache}/gradle
rm -rf $ANDROID_STUDIO_GRADLE_CONFIG
ln -sf ${local_container_cache}/gradle $ANDROID_STUDIO_GRADLE_CONFIG

# Android Studio Java cache
ANDROID_STUDIO_JAVA_CONFIG=${HOME}/.java
mkdir -p ${local_container_cache}/java
rm -rf $ANDROID_STUDIO_JAVA_CONFIG
ln -sf ${local_container_cache}/java $ANDROID_STUDIO_JAVA_CONFIG

# Android Studio Dart config
ANDROID_STUDIO_DART_TOOL_CONFIG=${HOME}/.dart-tool
mkdir -p ${local_container_cache}/.dart-tool
rm -rf $ANDROID_STUDIO_DART_TOOL_CONFIG
ln -sf ${local_container_cache}/.dart-tool $ANDROID_STUDIO_DART_TOOL_CONFIG

# Android Studio Flutter config
ANDROID_STUDIO_FLUTTER_CONFIG=${HOME}/flutter
rsync -av $ANDROID_STUDIO_FLUTTER_CONFIG ${local_container_cache}
rm -rf $ANDROID_STUDIO_FLUTTER_CONFIG
ln -sf ${local_container_cache}/flutter $ANDROID_STUDIO_FLUTTER_CONFIG

# Android Studio Pub config
ANDROID_STUDIO_PUB_CACHE_CONFIG=${HOME}/.pub-cache
rsync -av $ANDROID_STUDIO_PUB_CACHE_CONFIG ${local_container_cache}
rm -rf $ANDROID_STUDIO_PUB_CACHE_CONFIG
ln -sf ${local_container_cache}/.pub-cache $ANDROID_STUDIO_PUB_CACHE_CONFIG

# Android Studio SDK
ANDROID_STUDIO_HOME=${HOME}/Android
rsync -av $ANDROID_STUDIO_HOME ${local_container_cache}
rm -rf $ANDROID_STUDIO_HOME
ln -sf ${local_container_cache}/Android $ANDROID_STUDIO_HOME

# Android Studio Cache
ANDROID_STUDIO_CACHE=${HOME}/.android
rsync -av $ANDROID_STUDIO_CACHE ${local_container_cache}
rm -rf $ANDROID_STUDIO_CACHE
ln -sf ${local_container_cache}/.android $ANDROID_STUDIO_CACHE

# Android Studio Dart server config
ANDROID_STUDIO_DART_SERVER=${HOME}/.dartServer
mkdir -p ${local_container_cache}/.dartServer
rm -rf $ANDROID_STUDIO_DART_SERVER
ln -sf ${local_container_cache}/.dartServer $ANDROID_STUDIO_DART_SERVER

# Bash history
BASH_HISTORY_PATH=${HOME}/.bash_history
mkdir -p ${local_container_cache}
rm -f $BASH_HISTORY_PATH
ln -sf ${local_container_cache}/.bash_history $BASH_HISTORY_PATH

android_studio_dir=${LOCAL_ANDROID_STUDIO_DIR:-${PWD}}

caches_refresh_success=true