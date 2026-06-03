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


ENABLE_AUDIO="${ENABLE_AUDIO:-0}"
if [ "$ENABLE_AUDIO" = "1" ]; then
    # 🔊 Start a persistent PulseAudio daemon for the whole container session
    pulseaudio \
        --daemonize=no \
        --system=false \
        --disallow-exit \
        --exit-idle-time=-1 \
        --log-target=stderr &
    bg_pids+=("$!")

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

if [ ${VEGITO_DOCKER_DEBIAN_DESKTOP_X_CONTAINER_DISPLAY_START:-"true"} = "true" ]; then
    echo "✅ VEGITO_DOCKER_DEBIAN_DESKTOP_X_CONTAINER_DISPLAY_START is set to true"

    # -------------------------------------------------------------------
    # GPU mode auto-detection
    # -------------------------------------------------------------------

    if command -v nvidia-smi >/dev/null 2>&1 &&
        nvidia-smi >/dev/null 2>&1; then
        if [ -z "${VEGITO_DOCKER_DEBIAN_DESKTOP_X_GPU_MODE:-}" ]; then
            echo "✅ NVIDIA GPU acceleration detected -> using Wayland GPU mode"
            export VEGITO_DOCKER_DEBIAN_DESKTOP_X_GPU_MODE="wayland"
        fi
    fi

    if [ -z "${VEGITO_DOCKER_DEBIAN_DESKTOP_X_GPU_MODE:-}" ]; then
        export VEGITO_DOCKER_DEBIAN_DESKTOP_X_GPU_MODE="swiftshader_indirect"
        echo "ℹ️ No GPU acceleration detected -> using SwiftShader fallback"
    fi

    case "${VEGITO_DOCKER_DEBIAN_DESKTOP_X_GPU_MODE}" in
        "host")
            echo "🖥️ Starting host Xorg display mode"
            source /usr/local/bin/nvidia-gl-env.sh
            xorg-display-start-host.sh
            ;;

        "wayland")
            echo "🖥️ Starting Wayland GPU display mode"
            source /usr/local/bin/nvidia-gl-env.sh
            xwayland-display-start.sh
            ;;

        "swiftshader_indirect" | "guest")
            echo "🖥️ Starting SwiftShader software rendering mode"
            xvfb-display-start.sh
            ;;

        *)
            echo "⚠️ Unknown VEGITO_DOCKER_DEBIAN_DESKTOP_X_GPU_MODE='${VEGITO_DOCKER_DEBIAN_DESKTOP_X_GPU_MODE}', falling back to SwiftShader"
            xvfb-display-start.sh
            ;;
    esac
fi
 
