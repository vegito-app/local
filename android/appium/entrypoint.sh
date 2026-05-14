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

android_adb_key=${LOCAL_ANDROID_ADB_KEY_PATH:-~/.android/adbkey}
android_adb_pubkey=${LOCAL_ANDROID_ADB_KEY_PUB_PATH:-~/.android/adbkey.pub}

[ -d ~/.android ] || mkdir -p ~/.android
if [ ! -f $android_adb_key ] || [ ! -f $android_adb_pubkey ]; then
    echo "[entrypoint] Generating ADB keypair at $android_adb_key and $android_adb_pubkey..."
    adb keygen $android_adb_key
else
    echo "[entrypoint] Existing ADB keypair detected, skipping generation."
fi

android-emulator-entrypoint.sh "$@"

