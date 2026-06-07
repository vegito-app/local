#!/bin/bash

set -euo pipefail

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

XPRA_DEFAULT_ARGS_ARRAY=()
read -ra XPRA_DEFAULT_ARGS_ARRAY <<< "${XPRA_DEFAULT_ARGS:-}"

XPRA_ARGS_ARRAY=()
read -ra XPRA_ARGS_ARRAY <<< "${XPRA_ARGS:-}"

XPRA_ARGS_ARRAY=(
    "${XPRA_DEFAULT_ARGS_ARRAY[@]}"
    "${XPRA_ARGS_ARRAY[@]}"
)

# 🔊 Audio
ENABLE_AUDIO="${ENABLE_AUDIO:-0}"
if [ "$ENABLE_AUDIO" = "1" ]; then
    echo "🔊 Audio on"
    XPRA_ARGS_ARRAY+=(
        --speaker=on
        --microphone=off 
    )
else
    echo "🔇 Audio off"
    XPRA_ARGS_ARRAY+=(
        --speaker=off
        --microphone=off
    )
fi

echo "🌀 XPRA arguments:"
printf '  %s\n' "${XPRA_ARGS_ARRAY[@]}"

echo "🌀 Starting Xpra on ${display}"
xpra start "${display}" \
    --bind-tcp=0.0.0.0:5901 \
    --env=DISPLAY="${display}" \
    --env=PATH="${PATH}" \
    --no-daemon \
    "${XPRA_ARGS_ARRAY[@]}" \
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

wait $display_pid