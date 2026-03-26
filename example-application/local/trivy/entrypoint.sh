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

if [ "${LOCAL_TRIVY_CACHES_REFRESH:-false}" = "true" ]; then
    caches-refresh.sh
fi

if [ $# -eq 0 ]; then
  echo "[entrypoint] No command passed, entering sleep infinity to keep container alive"
  wait "${bg_pids[@]}"
  echo "[entrypoint] All background processes have exited, container will stop now."
else
  echo "[entrypoint] Executing passed command: $*"
  exec "$@"
fi