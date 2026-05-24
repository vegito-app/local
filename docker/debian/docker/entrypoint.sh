#!/bin/bash

set -euo pipefail

# Nettoyage du flag d'état à chaque arrêt
rm -f /tmp/.dockerd-rootless-ready

# 📌 List of PIDs of background processes
bg_pids=()

# 🧹 Function called at the end of the script to kill background processes
kill_jobs() {
  rm -f /tmp/.dockerd-rootless-ready
  echo "🧼 Cleaning up background processes..."
  for pid in "${bg_pids[@]}"; do
    kill "$pid" || true
    wait "$pid" 2>/dev/null || true
  done
}

# 🚨 Register cleanup function to run on script exit
trap kill_jobs EXIT

LOCAL_USER="$(id -un)"

if ! grep -q "^${LOCAL_USER}:" /etc/subuid; then
    echo "${LOCAL_USER}:100000:65536" | sudo tee -a /etc/subuid
fi

if ! grep -q "^${LOCAL_USER}:" /etc/subgid; then
    echo "${LOCAL_USER}:100000:65536" | sudo tee -a /etc/subgid
fi

exec "$@"