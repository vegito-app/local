#!/bin/bash

set -euo pipefail

DISPLAY="${DISPLAY:-:20}"
export DISPLAY

# Attendre que le flag /tmp/.xdisplay-ready soit présent (timeout 60s)
timeout=60
echo "Waiting for display server to be ready (flag /tmp/.xdisplay-ready)..."
for i in $(seq 1 $timeout); do
    if [ -f /tmp/.xdisplay-ready ]; then
        echo "✅ X display is ready!"
        break
    fi
    sleep 1
done

if [ ! -f /tmp/.xdisplay-ready ]; then
    echo "❌ Timeout waiting for display server (flag /tmp/.xdisplay-ready). Aborting Android Studio launch."
    exit 1
fi

pkill -x studio || true 
xset r on
studio