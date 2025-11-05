#!/bin/bash

set -euo pipefail

# List to hold background job PIDs
bg_pids=()

# Function to kill background jobs when script ends
kill_jobs() {
    echo "Killing background jobs"
    for pid in "${bg_pids[@]}"; do
        kill "$pid"
        wait "$pid" 2>/dev/null
    done
}

# Trap to call kill_jobs on script exit
trap kill_jobs EXIT

socat TCP-LISTEN:7900,fork,reuseaddr TCP:android-appium:5900 >> /tmp/socat-android-appium-x11vnc-5900.log 2>&1 &
bg_pids+=("$!")
socat TCP-LISTEN:7901,fork,reuseaddr TCP:android-appium:5901 >> /tmp/socat-android-appium-xpra-5901.log 2>&1 &
bg_pids+=("$!")
socat TCP-LISTEN:6037,fork,reuseaddr TCP:android-appium:5037 >> /tmp/socat-android-appium-adb-5037.log 2>&1 &
bg_pids+=("$!")
socat TCP-LISTEN:5723,fork,reuseaddr TCP:android-appium:4723 >> /tmp/socat-android-appium-adb-4723.log 2>&1 &
bg_pids+=("$!")

docker_compose=${LOCAL_DOCKER_COMPOSE:-docker compose -f ${LOCAL_DIR}/docker-compose.yml}

${docker_compose} up android-appium 2>&1
