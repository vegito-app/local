#!/bin/bash

set -euo pipefail

local_container_cache=${LOCAL_ANDROID_STUDIO_CONTAINER_CACHE:-${LOCAL_DIR:-${PWD}}/.containers/android-studio}
mkdir -p $local_container_cache

android_release_keystore=${LOCAL_ANDROID_RELEASE_KEYSTORE_PATH:-~/.android/release.keystore}
if [ -f "$android_release_keystore" ] && [ ! -f ~/.android/release.keystore ]; then
    echo "[entrypoint] Linking existing local release keystore from $android_release_keystore to ~/.android/release.keystore"
    ln -sf "$android_release_keystore" ~/.android/release.keystore
fi
local_container_cache=${LOCAL_ANDROID_STUDIO_CONTAINER_CACHE:-${LOCAL_DIR:-${PWD}}/.containers/android-studio}
mkdir -p $local_container_cache


android_adb_key=${LOCAL_ANDROID_ADB_KEY_PATH:-~/.android/adbkey}
android_adb_pubkey=${LOCAL_ANDROID_ADB_KEY_PUB_PATH:-~/.android/adbkey.pub}
[ -d ~/.android ] || mkdir -p ~/.android
if [ ! -f $android_adb_key ] || [ ! -f $android_adb_pubkey ]; then
    echo "[entrypoint] Generating ADB keypair at $android_adb_key and $android_adb_pubkey..."
    adb keygen $android_adb_key
else
    echo "[entrypoint] Existing ADB keypair detected, skipping generation."
fi

android_release_keystore=${LOCAL_ANDROID_RELEASE_KEYSTORE_PATH:-~/.android/release.keystore}
android_release_keystore_alias=${LOCAL_ANDROID_RELEASE_KEYSTORE_ALIAS_NAME:-vegito-local-release}
android_release_keystore_store_pass=${LOCAL_ANDROID_RELEASE_KEYSTORE_STORE_PASS:-android}
android_release_keystore_key_pass=${LOCAL_ANDROID_RELEASE_KEYSTORE_KEY_PASS:-android}
android_release_keystore_dname=${LOCAL_ANDROID_RELEASE_KEYSTORE_DNAME:-"CN=Vegito, OU=Dev, O=Vegito, L=Paris, S=IDF, C=FR"}

if [ ! -f $android_release_keystore ]; then
    echo "[entrypoint] No release.keystore found, generating via Keytool..."
    keytool -genkey -v \
      -keystore $android_release_keystore \
      -alias $android_release_keystore_alias \
      -keyalg RSA \
      -keysize 2048 \
      -validity 10000 \
      -storepass $android_release_keystore_store_pass \
      -keypass $android_release_keystore_key_pass \
      -dname "$android_release_keystore_dname"
else
    echo "[entrypoint] Existing release.keystore found, skipping generation."
fi

if [ "${LOCAL_ANDROID_STUDIO_CONTAINER_INSTALL:-true}" = "true" ]; then
    android-studio-container-install.sh &
    bg_pids+=("$!")
fi

export XPRA_ENV_ARGS=()

XPRA_ENV_ARGS+=("--env=ANDROID_HOME=${ANDROID_HOME}")
XPRA_ENV_ARGS+=("--env=ANDROID_HOST=${ANDROID_HOST}")
XPRA_ENV_ARGS+=("--env=ANDROID_SDK=${ANDROID_SDK}")
XPRA_ENV_ARGS+=("--env=FLUTTER_HOME=${FLUTTER_HOME}")
XPRA_ENV_ARGS+=("--env=STUDIO_PATH=${STUDIO_PATH}")

# 📥 Use Appium entrypoint to setup underlying Android emulator with Appium
android-appium-entrypoint.sh echo " [entrypoint] Android Appium setup done"

exec "$@"