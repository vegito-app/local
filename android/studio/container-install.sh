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
# Drop lock eventually remaining after previous container run exit
rm -f ${ANDROID_STUDIO_CONFIG}/AndroidStudio2024.1/.lock


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

android_studio_dir=${LOCAL_ANDROID_STUDIO_DIR:-${PWD}}

caches_refresh_success=true