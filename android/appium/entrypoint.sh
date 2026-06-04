#!/bin/bash

set -euo pipefail

android_adb_key=${LOCAL_ANDROID_ADB_KEY_PATH:-~/.android/adbkey}
android_adb_pubkey=${LOCAL_ANDROID_ADB_KEY_PUB_PATH:-~/.android/adbkey.pub}

[ -d ~/.android ] || mkdir -p ~/.android
if [ ! -f $android_adb_key ] || [ ! -f $android_adb_pubkey ]; then
    echo "[entrypoint] Generating ADB keypair at $android_adb_key and $android_adb_pubkey..."
    adb keygen $android_adb_key
else
    echo "[entrypoint] Existing ADB keypair detected, skipping generation."
fi

android-emulator-entrypoint.sh echo " [entrypoint] Android Emulator setup done"

exec "$@"

