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


forward_firebase_port() {
    local port="$1"
    local log_file="/tmp/socat-firebase-emulators-${port}.log"

    echo "🔥 Firebase Emulator: 127.0.0.1:${port} -> firebase-emulators:${port}"

    socat \
        "TCP-LISTEN:${port},bind=127.0.0.1,fork,reuseaddr" \
        "TCP:firebase-emulators:${port}" \
        > "${log_file}" 2>&1 &
    bg_pids+=("$!")
}

# Firebase CLI internal services bind to loopback only.
# firebase-emulators re-exposes them on dedicated bridge ports so that
# containers running the Emulator UI browser can recreate them locally.
forward_firebase_internal_port() {
    local local_port="$1"
    local remote_port="$2"
    local log_file="/tmp/socat-firebase-emulators-${remote_port}.log"

    echo "🔥 Firebase Emulator UI: 127.0.0.1:${local_port} -> firebase-emulators:${remote_port}"

    socat \
        "TCP-LISTEN:${local_port},bind=127.0.0.1,fork,reuseaddr" \
        "TCP:firebase-emulators:${remote_port}" \
        > "${log_file}" 2>&1 &
    bg_pids+=("$!")
}

# Ports Firebase normaux : même port des deux côtés
forward_firebase_port 9000
forward_firebase_port 9099
forward_firebase_port 9150
forward_firebase_port 9199
forward_firebase_port 8085
forward_firebase_port 8090
forward_firebase_port 5001
forward_firebase_port 4000

# Ports internes UI : port de transport différent
forward_firebase_internal_port 9499 9599
forward_firebase_internal_port 9299 9399
forward_firebase_internal_port 4500 4501
forward_firebase_internal_port 4400 4401

docker_compose=${LOCAL_DOCKER_COMPOSE:-docker compose -f ${LOCAL_DIR}/docker-compose.yml}

${docker_compose} up firebase-emulators 2>&1