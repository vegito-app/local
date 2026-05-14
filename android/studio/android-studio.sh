#!/bin/bash

set -euo pipefail


if [ ! "${LOCAL_ANDROID_STUDIO_ON_START}" = "true" ]; then
    echo "ℹ️ Skipping Android Studio start as LOCAL_ANDROID_STUDIO_ON_START is not set to true, exit"
    exit 0
fi

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

rm -f ~/.android/avd/*/*.lock
rm -f ~/.android/avd/*.ini.lock

xset r on || true

exec $HOME/android-studio/bin/studio