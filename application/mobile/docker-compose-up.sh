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

socat TCP-LISTEN:8900,fork,reuseaddr TCP:vegito-mobile:5900 >> /tmp/socat-vegito-mobile-x11vnc-5900.log 2>&1 &
bg_pids+=("$!")
socat TCP-LISTEN:8901,fork,reuseaddr TCP:vegito-mobile:5901 >> /tmp/socat-vegito-mobile-xpra-5901.log 2>&1 &
bg_pids+=("$!")
socat TCP-LISTEN:7037,fork,reuseaddr TCP:vegito-mobile:5037 >> /tmp/socat-vegito-mobile-adb-5037.log 2>&1 &
bg_pids+=("$!")

docker_compose=${LOCAL_DOCKER_COMPOSE:-docker compose -f ${VEGITO_MOBILE_DIR}/docker-compose.yml}

$docker_compose up application-mobile 2>&1
