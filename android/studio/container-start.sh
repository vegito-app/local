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

# Start Appium runtime (critical service)
android-appium-start.sh &
appium_pid="$!"

export DISPLAY="${DISPLAY:-:20}"

timeout=300

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


if [ "${LOCAL_ANDROID_STUDIO_ON_START:-true}" = "true" ]; then
    # Start Android Studio GUI (non critical)
    echo "⏳ Starting Android Studio..."
    studio >/tmp/android-studio.log 2>&1 &
fi

echo "ℹ️ Android Studio is started as a detached GUI application."
echo "ℹ️ Container lifecycle is tied to Appium runtime, not Studio."

# Keep runtime alive while Appium is alive
wait "$appium_pid"

