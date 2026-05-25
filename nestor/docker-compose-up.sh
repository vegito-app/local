#!/bin/bash

set -exuo pipefail

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

socat TCP-LISTEN:2377,fork,reuseaddr TCP:nestor:2376 > /tmp/socat-nestor-2376.log 2>&1 &
bg_pids+=("$!")

socat TCP-LISTEN:5903,fork,reuseaddr TCP:nestor:5901 > /tmp/socat-nestor-5901.log 2>&1 &
bg_pids+=("$!")

docker_compose=${LOCAL_DOCKER_COMPOSE:-docker compose -f ${LOCAL_DIR}/docker-compose.yml}

${docker_compose} up nestor 2>&1