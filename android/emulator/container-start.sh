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

desktop-x-start.sh &
display_pid=$!

if [ "${LOCAL_ANDROID_EMULATOR_AVD_ON_START}" != "true" ]; then
    echo "ℹ️ Skipping AVD start as LOCAL_ANDROID_EMULATOR_AVD_ON_START is not set to true."
    exit 0
fi

android-emulator-avd-start.sh &
bg_pids+=($!)

# Wait for emulator to exit
wait $display_pid