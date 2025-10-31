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

export LOCAL_USER_ID=$(id -u)

if [ "${LOCAL_CLARINET_DEVNET_CACHES_REFRESH:-false}" = "true" ]; then
    clarinet-caches-refresh.sh
fi

dockerd-entrypoint.sh --dns=8.8.8.8 --dns=8.8.4.4 &
bg_pids+=("$!")


export DOCKER_HOST=unix:///run/user/$LOCAL_USER_ID/docker.sock

until docker info >/dev/null 2>&1; do echo waiting dockerd startup ; sleep 1 ; done

docker info

TARGET_PORT=2375 LISTEN_PORT=2376 localproxy &
bg_pids+=("$!")

mkdir -p ${HOME}/.docker/run
ln -sf /run/user/$LOCAL_USER_ID/docker.sock ${HOME}/.docker/run/docker.sock


# Set inotify watches limit
echo fs.inotify.max_user_watches=524288 |  sudo tee -a /etc/sysctl.conf; sudo sysctl -p
# Set inotify watches limit for rootless dockerd
echo fs.inotify.max_user_watches=524288 | sudo tee -a /run/user/$LOCAL_USER_ID/sysctl.conf
sudo sysctl -p /run/user/$LOCAL_USER_ID/sysctl.conf

if [ $# -eq 0 ]; then
  echo "[entrypoint] No command passed, entering sleep infinity to keep container alive"
  wait "${bg_pids[@]}"
else
  exec "$@"
fi
