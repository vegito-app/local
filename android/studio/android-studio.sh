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

# Start Appium in the background
android-appium-start.sh &
bg_pids+=($!)

if [ ! "${LOCAL_ANDROID_STUDIO_ON_START}" = "true" ]; then
    echo "ℹ️ Skipping Android Studio start as LOCAL_ANDROID_STUDIO_ON_START is not set to true, exit"
    exit 0
fi

export DISPLAY="${DISPLAY:-:20}"

timeout=60

echo "⏳ Waiting for X display..."

for i in $(seq 1 $timeout); do
    [ -f /tmp/.xdisplay-ready ] && break
    sleep 1
done

if [ ! -f /tmp/.xdisplay-ready ]; then
    echo "❌ Display not ready"
    exit 1
fi

rm -f ~/.android/avd/*/*.lock
rm -f ~/.android/avd/*.ini.lock

xset r on || true

# Start Appium in the background
studio &
bg_pids+=($!)

# Keep container alive
sleep infinity &
bg_pids+=($!)

# Wait background processes
if [ "${#bg_pids[@]}" -gt 0 ]; then
    wait "${bg_pids[@]}"
fi
