#!/bin/bash

set -euxo pipefail

# Nettoyage du flag d'état à chaque arrêt
rm -f /tmp/.xpra-ready

# 📌 List of PIDs of background processes
bg_pids=()

# 🧹 Function called at the end of the script to kill background processes
kill_jobs() {
    rm -f /tmp/.xpra-ready
    echo "🧼 Cleaning up background processes..."
    for pid in "${bg_pids[@]}"; do
        kill "$pid" || true
        wait "$pid" 2>/dev/null || true
    done
}

# 🚨 Register cleanup function to run on script exit
trap kill_jobs EXIT

display="${DISPLAY:?DISPLAY is required}"

unset XPRA_SERVER_SOCKET
unset XPRA_SESSION_DIR

XPRA_SOCKET_DIR="${XPRA_SOCKET_DIR:-$XDG_RUNTIME_DIR/xpra}"
mkdir -p "${XPRA_SOCKET_DIR}"

echo "🌀 Starting Xpra on ${display}"

xpra start "${display}" \
    --bind-tcp=0.0.0.0:5901 \
    --env=DISPLAY="${display}" \
    --env=PATH="${PATH}" \
    --no-daemon \
    "${XPRA_ARGS[@]}" \
    &

display_pid="$!"

XPRA_SOCKET="$XPRA_SOCKET_DIR/$(hostname)-${display#:}"
export XPRA_SERVER_SOCKET="$XPRA_SOCKET"

until [ -S "$XPRA_SOCKET" ]; do
    echo "⏳ Waiting for xpra socket..."
    sleep 1
done

echo "🌀 Xpra started successfully on ${display}."

if [ "$ENABLE_AUDIO" = "1" ]; then
    for i in $(seq 1 10); do
        if pactl info >/dev/null 2>&1; then
            echo "🔊 PulseAudio ready"
            break
        fi
        sleep 1
    done
fi

xpra info "socket://$XPRA_SERVER_SOCKET" | grep -Ei "nvenc|device_count|gpu.encodings"

# Création d'un flag indiquant que Xpra est prêt
echo "{\"status\":\"ready\",\"ts\":$(date +%s)}" > /tmp/.xpra-ready

echo "✅ Xpra started successfully."

if [ $# -eq 0 ]; then
  echo "[entrypoint] No command passed, waiting xpra to keep container alive"
  wait $display_pid
else
  bg_pids+=("$display_pid")
  exec "$@"
fi