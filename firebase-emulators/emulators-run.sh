#!/bin/bash

set -euo pipefail

# List to hold background job PIDs
bg_pids=()

# Function to kill background jobs when script ends
kill_jobs() {
    echo "Killing background jobs"
    for pid in "${bg_pids[@]}"; do
        kill "$pid" 2>/dev/null || true
        wait "$pid" 2>/dev/null || true
    done
}

# Trap to call kill_jobs on script exit
trap kill_jobs EXIT

echo "fs.inotify.max_user_watches=524288" | sudo tee /etc/sysctl.d/99-inotify.conf \
    && echo "fs.inotify.max_user_instances=1024" | sudo tee -a /etc/sysctl.d/99-inotify.conf \
    && sudo sysctl -p /etc/sysctl.d/99-inotify.conf || true

make local-firebase-emulators-install local-firebase-emulators-start &
bg_pids+=("$!")

# Firebase Emulator UI utilise certains services auxiliaires uniquement
# exposés sur localhost. On les réexpose sur le réseau Docker avec un
# port différent afin qu'un autre container puisse les ramener sur son
# propre localhost.
forward_loopback_port() {
    local source_port="$1"
    local bridge_port="$2"
    local timeout_seconds="${3:-60}"
    local elapsed=0

    echo "[firebase-emulators] Waiting for 127.0.0.1:${source_port}..."

    while ! nc -z 127.0.0.1 "${source_port}" 2>/dev/null; do
        if (( elapsed >= timeout_seconds )); then
            echo "[firebase-emulators] WARNING: 127.0.0.1:${source_port} unavailable after ${timeout_seconds}s; skipping bridge ${bridge_port}"
            return 0
        fi

        sleep 1
        ((elapsed += 1))
    done

    echo "[firebase-emulators] Port 127.0.0.1:${source_port} is ready"
    echo "[firebase-emulators] Forwarding 0.0.0.0:${bridge_port} -> 127.0.0.1:${source_port}"

    exec socat \
        "TCP-LISTEN:${bridge_port},bind=0.0.0.0,fork,reuseaddr" \
        "TCP:127.0.0.1:${source_port}"
}

# Emulator Hub
forward_loopback_port 4400 4401 &
bg_pids+=("$!")

# Logging
forward_loopback_port 4500 4501 &
bg_pids+=("$!")

# FireAlerts / trigger discovery
forward_loopback_port 9299 9399 &
bg_pids+=("$!")

# Auxiliary Firebase CLI
forward_loopback_port 9499 9599 &
bg_pids+=("$!")


if [ $# -eq 0 ]; then
    echo "[entrypoint] No command passed, entering sleep infinity to keep container alive"

    if [ "${#bg_pids[@]}" -gt 0 ]; then
        wait "${bg_pids[@]}"
    fi
else
    exec "$@"
fi