#!/bin/bash

set -euo pipefail

# List to hold background job PIDs
bg_pids=()

cleanup() {
    for pid in "${bg_pids[@]}"; do
        kill "$pid"
        wait "$pid" 2>/dev/null
    done
}

trap cleanup EXIT

# --- Configuration ---
export WG_IF="wg0"
export WG_SUBNET="10.9.0"
export WG_SERVER_IP="${WG_SUBNET}.1"
export WG_CLIENT_MACBOOK_IP="${WG_SUBNET}.2"
export WG_CLIENT_IPHONE6S_IP="${WG_SUBNET}.3"

# --- Démarrage du serveur WireGuard ---
wg-server-start.sh

# --- Démarrage des clients WireGuard ---
wg-client-connect.sh &
bg_pids+=($!)

# --- Affichage des infos WireGuard ---
sleep 2
wg-show.sh

# --- Démarrage du serveur NFS ---
if [[ "${CODESPACES:-}" == "true" ]]; then
  echo "🌐 Codespaces detected → NFS Ganesha"
  sudo -E nfs-start-ganesha.sh &
  bg_pids+=($!)
else
  echo "🖥️ Local environment → kernel NFS"
  nfs-start.sh &
  bg_pids+=($!)
fi

if [ $# -eq 0 ]; then
  echo "[entrypoint] No command passed, entering sleep infinity to keep container alive"
  wait ${bg_pids[@]}
else
  exec "$@"
fi