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

if [ "${LOCAL_CLARINET_CONTAINER_INSTALL:-true}" = "true" ]; then
    clarinet-container-install.sh
fi

debian-dockerd-entrypoint.sh "$@"