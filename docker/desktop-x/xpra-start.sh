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
default_dpi="96"
dpi="${DISPLAY_DPI:-$default_dpi}"

XPRA_ENCODING="${XPRA_ENCODING:-h264}"
XPRA_QUALITY="${XPRA_QUALITY:-80}"
XPRA_SPEED="${XPRA_SPEED:-70}"

XPRA_MIN_QUALITY="${XPRA_MIN_QUALITY:-30}"
XPRA_MIN_SPEED="${XPRA_MIN_SPEED:-30}"

XPRA_PROFILE_FLAGS="
    --encoding=${XPRA_ENCODING}
    --quality=${XPRA_QUALITY}
    --speed=${XPRA_SPEED}
    --min-quality=${XPRA_MIN_QUALITY}
    --min-speed=${XPRA_MIN_SPEED}
"

ENABLE_AUDIO="${ENABLE_AUDIO:-0}"

if [ "$ENABLE_AUDIO" = "1" ]; then
    XPRA_AUDIO_FLAGS="--speaker=on --microphone=off"
else
    XPRA_AUDIO_FLAGS="--speaker=off --microphone=off"
fi

unset XPRA_SERVER_SOCKET
unset XPRA_SESSION_DIR

XPRA_VIDEO_ENCODERS_FLAGS=""

if command -v nvidia-smi >/dev/null 2>&1 &&
    nvidia-smi >/dev/null 2>&1; then

    XPRA_VIDEO_ENCODERS_FLAGS="--video-encoders=${XPRA_VIDEO_ENCODERS:-nvenc}"
fi

XPRA_SOCKET_DIR="${XPRA_SOCKET_DIR:-$XDG_RUNTIME_DIR/xpra}"
mkdir -p "${XPRA_SOCKET_DIR}"

echo "🌀 Starting Xpra on ${DISPLAY}"

xpra start "${DISPLAY}" \
    --bind-tcp=0.0.0.0:5901 \
    --desktop-scaling=auto \
    --dpi="$dpi" \
    --env=DISPLAY="${display}" \
    --env=XPRA_NVENC_ENABLED=1 \
    --html=on \
    --no-daemon \
    --no-mdns \
    --resize-display=no \
    --socket-dir="$XPRA_SOCKET_DIR" \
    --socket-dirs="$XPRA_SOCKET_DIR" \
    --use-display \
    --webcam=no \
    ${XPRA_AUDIO_FLAGS} \
    ${XPRA_VIDEO_ENCODERS_FLAGS} \
    ${XPRA_PROFILE_FLAGS} &

display_pid="$!" && bg_pids+=("$!")

XPRA_SOCKET="$XPRA_SOCKET_DIR/$(hostname)-${display#:}"
export XPRA_SERVER_SOCKET="$XPRA_SOCKET"

until [ -S "$XPRA_SERVER_SOCKET" ]; do
    echo "⏳ Waiting for xpra socket..."
    sleep 1
done
echo "🌀 Xpra started successfully."
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
echo "{\"status\":\"ready\",\"ts\":$(date +%s)}" > /tmp/.xrpa-ready

echo "✅ Xpra started successfully."

if [ $# -eq 0 ]; then
  echo "[entrypoint] No command passed, waiting xpra to keep container alive"
  wait $display_pid
else
  bg_pids+=("$display_pid")
  exec "$@"
fi