#!/bin/bash

set -euo pipefail

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
            exec display-start-xorg-host.sh
            ;;

        "wayland")
            echo "🖥️ Starting Wayland GPU display mode"
            source /usr/local/bin/nvidia-gl-env.sh
            exec display-start-wayland.sh
            ;;

        "swiftshader_indirect" | "guest")
            echo "🖥️ Starting SwiftShader software rendering mode"
            exec display-start-xvfb.sh
            ;;

        *)
            echo "⚠️ Unknown VEGITO_DOCKER_DEBIAN_DESKTOP_X_GPU_MODE='${VEGITO_DOCKER_DEBIAN_DESKTOP_X_GPU_MODE}', falling back to SwiftShader"
            exec display-start-xvfb.sh
            ;;
    esac
fi
 
