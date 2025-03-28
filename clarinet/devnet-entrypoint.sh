#!/bin/bash

set -eu

# List to hold background job PIDs
bg_pids=()

# Function to kill background jobs when script ends
kill_jobs() {
    echo "Killing clarinet background jobs"
    for pid in "${bg_pids[@]}"; do
        kill "$pid"
        wait "$pid" 2>/dev/null
    done
}

# Trap to call kill_jobs on script exit
trap kill_jobs EXIT

dockerd-entrypoint.sh --dns=8.8.8.8 --dns=8.8.4.4 &
bg_pids+=("$!")

TARGET_PORT=2375 LISTEN_PORT=2376 localproxy &
bg_pids+=("$!")

#mkdir -p /home/devuser/.docker/run
#ln -s /run/user/1000/docker.sock /home/devuser/.docker/run/docker.sock


export DOCKER_HOST=unix:///run/user/1000/docker.sock
until docker info >/dev/null 2>&1; do echo waiting dockerd startup ; sleep 1 ; done
docker info
TARGET_PORT=2375 LISTEN_PORT=2376 localproxy &
mkdir -p /home/devuser/.docker/run
ln -s /run/user/1000/docker.sock /home/devuser/.docker/run/docker.sock
make clarinet-devnet-start &

exec "$@"
