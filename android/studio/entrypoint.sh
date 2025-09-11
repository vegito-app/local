#!/bin/bash

set -euo pipefail

# 📌 List of PIDs of background processes
bg_pids=()

# 🧹 Function called at the end of the script to kill background processes
kill_jobs() {
    echo "🧼 Cleaning up background processes..."
    for pid in "${bg_pids[@]}"; do
        kill "$pid" || true
        wait "$pid" 2>/dev/null || true
    done
}

# 🚨 Register cleanup function to run on script exit

trap kill_jobs EXIT

(android-emulator-entrypoint.sh) &
bg_pids+=("$!")

local_container_cache=${LOCAL_ANDROID_STUDIO_CONTAINER_CACHE:-${LOCAL_DIR:-${PWD}}/.containers/android-studio}
mkdir -p $local_container_cache


android_adb_key=${LOCAL_ANDROID_ADB_KEY_PATH:-~/.android/adbkey}
android_adb_pubkey=${LOCAL_ANDROID_ADB_KEY_PUB_PATH:-~/.android/adbkey.pub}
mkdir -p ~/.android
if [ ! -f $android_adb_key ] || [ ! -f $android_adb_pubkey ]; then
    echo "[entrypoint] Generating ADB keypair at $android_adb_key and $android_adb_pubkey..."
    adb keygen -a -n $android_adb_key
else
    echo "[entrypoint] Existing ADB keypair detected, skipping generation."
fi

android_release_keystore=${LOCAL_ANDROID_RELEASE_KEYSTORE_PATH:-~/.android/release.keystore}
if [ ! -f $android_release_keystore ]; then
    echo "[entrypoint] No release.keystore found, generating via Makefile..."
    LOCAL_ANDROID_STUDIO="" make -C ../.. local-android-release-keystore
else
    echo "[entrypoint] Existing release.keystore found, skipping generation."
fi

if [ "${LOCAL_ANDROID_STUDIO_ON_START}" = "true" ]; then
    (android-studio.sh) &
fi

if [ "${LOCAL_ANDROID_STUDIO_CACHES_REFRESH}" = "true" ]; then
    caches-refresh.sh
fi

if [ $# -eq 0 ]; then
  echo "[entrypoint] No command passed, entering sleep infinity to keep container alive"
  wait "${bg_pids[@]}"
else
  exec "$@"
fi
