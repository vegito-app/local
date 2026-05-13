#!/bin/bash

set -euo pipefail

export DISPLAY="${DISPLAY:-:20}"

timeout=60

echo "⏳ Waiting for X display..."

for i in $(seq 1 $timeout); do
    [ -f /tmp/.xdisplay-ready ] && break
    sleep 1
done

if [ ! -f /tmp/.xdisplay-ready ]; then
    echo "❌ Display not ready"
    exit 1
fi

xset r on || true

exec $HOME/android-studio/bin/studio