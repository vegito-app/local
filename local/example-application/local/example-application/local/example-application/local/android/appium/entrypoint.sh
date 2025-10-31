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

android-emulator-entrypoint.sh &
bg_pids+=("$!")


# ⏳ Attente du boot complet de l'émulateur
echo "⏳ Waiting for full Android boot..."

adb wait-for-device

until adb shell getprop sys.boot_completed | grep -q "1"; do
  echo "⏳ Android not booted yet..."
  sleep 2
done

while [[ "$(adb shell getprop init.svc.bootanim 2>/dev/null)" != *"stopped"* ]]; do
  echo "🎞️ Boot animation still running..."
  sleep 2
done

# Optionnel : check de réactivité ADB shell
until adb shell "echo ok" | grep -q "ok"; do
  echo "🔁 Waiting for ADB shell..."
  sleep 2
done

echo "✅ Android fully booted. Now launching Appium..."

exec appium --address 0.0.0.0 --port 4723 \
    --session-override --log-level info \
    --allow-insecure uiautomator2:adb_shell