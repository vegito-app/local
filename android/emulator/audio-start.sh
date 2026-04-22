#!/bin/bash
set -euo pipefail

pulseaudio --start --exit-idle-time=-1
timeout 30 bash -c '
until pactl info >/dev/null 2>&1; do
  echo "⏳ Waiting for PulseAudio to start...";
  sleep 2
done
'

echo "🔊 Initializing PulseAudio null sink..."

pactl load-module module-null-sink sink_name=xpra_sink || true
pactl set-default-sink xpra_sink || true

echo "🔊 Available sinks:"
pactl list short sinks || true

echo "🔊 Audio pipeline ready"

export PULSE_RUNTIME_PATH="$XDG_RUNTIME_DIR/pulse"
export PULSE_SERVER="unix:$XDG_RUNTIME_DIR/pulse/native"