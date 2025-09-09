#!/bin/bash

set -eu

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

android-emulator-entrypoint.sh &
bg_pids+=("$!")

if [ "${LOCAL_ANDROID_STUDIO_CACHES_REFRESH}" = "true" ]; then
    caches-refresh.sh &
    bg_pids+=("$!")
fi
local_container_cache=${LOCAL_ANDROID_STUDIO_CONTAINER_CACHE:-${LOCAL_DIR:-${PWD}}/.containers/android-studio}
mkdir -p $local_container_cache

android_release_keystore=${LOCAL_ANDROID_RELEASE_KEYSTORE_PATH:-~/.android/release.keystore}
if [ -f "$android_release_keystore" ]; then
    echo "[entrypoint] Linking existing local release keystore from $android_release_keystore to ~/.android/release.keystore"
    ln -sf "$android_release_keystore" ~/.android/release.keystore
fi

mkdir -p ~/.android
if [ ! -f ~/.android/adbkey ] || [ ! -f ~/.android/adbkey.pub ]; then
    echo "[entrypoint] Generating ADB keypair at ~/.android/adbkey{,.pub}..."
    adb keygen -a -n ~/.android/adbkey
else
    echo "[entrypoint] Existing ADB keypair detected, skipping generation."
fi

if [ ! -f ~/.android/release.keystore ]; then
    echo "[entrypoint] No release.keystore found, generating via Makefile..."
    LOCAL_ANDROID_STUDIO="" make -C .. local-android-release-keystore
else
    echo "[entrypoint] Existing release.keystore found, skipping generation."
fi

if [ "${LOCAL_ANDROID_STUDIO_ON_START}" = "true" ]; then
    android-studio.sh &
    bg_pids+=("$!")
fi

if [ $# -eq 0 ]; then
  echo "[entrypoint] No command passed, entering sleep infinity to keep container alive"
  wait "${bg_pids[@]}" &
  sleep infinity
else
  exec "$@"
fi
