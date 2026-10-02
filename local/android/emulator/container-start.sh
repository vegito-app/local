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

for i in $(seq 1 300); do
    if [ -f /tmp/.xdisplay-ready ]; then
        break
    fi
    echo "⏳ Waiting for X display..."
    sleep 1
done

if [ ! -f /tmp/.xdisplay-ready ]; then
    echo "❌ Display not ready"
    exit 1
fi

if [ "${LOCAL_ANDROID_EMULATOR_AVD_ON_START}" = "true" ]; then
    android-emulator-avd-start.sh &
    bg_pids+=($!)
else
    echo "ℹ️ Skipping AVD start as LOCAL_ANDROID_EMULATOR_AVD_ON_START is not set to true."
fi

forward_port() {
    local local_port="$1"
    local remote_host="$2"
    local remote_port="${3:-$local_port}"

    echo "🔀 127.0.0.1:${local_port} -> ${remote_host}:${remote_port}"

    socat \
        "TCP-LISTEN:${local_port},bind=127.0.0.1,fork,reuseaddr" \
        "TCP:${remote_host}:${remote_port}" \
        > "/tmp/socat-${remote_host}-${remote_port}.log" 2>&1 &

    bg_pids+=("$!")
}

# Firebase emulators
forward_port 4000 firebase-emulators
forward_port 5001 firebase-emulators
forward_port 8085 firebase-emulators
forward_port 8090 firebase-emulators
forward_port 9000 firebase-emulators
forward_port 9099 firebase-emulators
forward_port 9150 firebase-emulators
forward_port 9199 firebase-emulators

# Firebase CLI internal ports re-exposed by firebase-emulators
forward_port 4400 firebase-emulators 4401
forward_port 4500 firebase-emulators 4501
forward_port 9299 firebase-emulators 9399
forward_port 9499 firebase-emulators 9599

# access to backend using localhost (position retrieval unauthorized using insecure http frontend with google-chrome)
socat TCP-LISTEN:8080,fork,reuseaddr TCP:application-backend:8080 > /tmp/socat-backend-8080.log 2>&1 &
bg_pids+=("$!")

# access to debug backend using localhost (position retrieval unauthorized using insecure http frontend with google-chrome)
socat TCP-LISTEN:8888,fork,reuseaddr TCP:devcontainer:8888 > /tmp/socat-devcontainer-8888.log 2>&1 &
bg_pids+=("$!")

# Wait for emulator to exit
wait $display_pid