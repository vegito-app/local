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

docker_compose=${LOCAL_DOCKER_COMPOSE:-docker compose -f ${LOCAL_DIR}/docker-compose.yml}

${docker_compose} up firebase-emulators 2>&1