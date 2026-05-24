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

export XPRA_SOCKET_DIR="$XDG_RUNTIME_DIR/xpra"
export XPRA_SOCKET_DIRS="$XPRA_SOCKET_DIR"
mkdir -p "$XPRA_SOCKET_DIR"

# start a dbus session (required by pulseaudio/xpra)
eval "$(dbus-launch --sh-syntax)"
export DBUS_SESSION_BUS_ADDRESS
export DBUS_SESSION_BUS_PID


ENABLE_AUDIO="${ENABLE_AUDIO:-0}"
if [ "$ENABLE_AUDIO" = "1" ]; then
    # 🔊 Start a persistent PulseAudio daemon for the whole container session
    pulseaudio \
        --daemonize=yes \
        --system=false \
        --disallow-exit \
        --exit-idle-time=-1 \
        --log-target=stderr

    for i in $(seq 1 10); do
        if pactl info >/dev/null 2>&1; then
            echo "🔊 PulseAudio ready"
            break
        fi
        echo "⏳ Waiting for PulseAudio..."
        sleep 1
    done

    # 🔍 Debug PulseAudio availability
    pactl info
fi

exec "$@"