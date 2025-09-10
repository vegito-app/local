#!/bin/bash

set -euo pipefail

# ================================
#  SAFE REMOTE DISPLAY FOR CONTAINER
#  - Uses Xvfb (virtual framebuffer)
#  - Xpra serves an HTML5 client (noVNC unnecessary)
#  - No Xorg, no access to host DISPLAY :0, no NVIDIA driver coupling
# ================================

# 📌 Track background PIDs
bg_pids=()
kill_jobs() {
  echo "🧼 Cleaning up background processes..."
  for pid in "${bg_pids[@]:-}"; do
    kill "$pid" 2>/dev/null || true
    wait "$pid" 2>/dev/null || true
  done
}
trap kill_jobs EXIT

# 🧰 Runtime dir (for X sockets etc.)
export XDG_RUNTIME_DIR="/run/user/$(id -u)"
mkdir -p "$XDG_RUNTIME_DIR"
chmod 700 "$XDG_RUNTIME_DIR" 2>/dev/null || true

# 🖥️ Defaults (overridable)
resolution="${DISPLAY_RESOLUTION:-1920x1080}"
depth="${DISPLAY_DEPTH:-24}"
dpi="${DISPLAY_DPI:-96}"
framerate="${DISPLAY_FRAMERATE:-60}" # not used by Xvfb, kept for compatibility

# We force a private virtual display so we never poke host :0
export DISPLAY="${DISPLAY:-:99}"

# Extract width/height
width="${resolution%x*}"
height="${resolution#*x}"

# 🚀 Start Xvfb (virtual X server)
# -noreset keeps it alive across client reconnects
# -screen 0 WIDTHxHEIGHTxDEPTH
Xvfb "$DISPLAY" -screen 0 "${width}x${height}x${depth}" -dpi "$dpi" -noreset +extension GLX +extension RANDR &
bg_pids+=("$!")

# Wait for the X socket to appear
for i in $(seq 1 30); do
  if xdpyinfo -display "$DISPLAY" >/dev/null 2>&1; then
    break
  fi
  echo "⏳ Waiting for Xvfb on $DISPLAY... ($i)"
  sleep 1
  if [ "$i" -eq 30 ]; then
    echo "❌ Xvfb did not come up" >&2
    exit 1
  fi
done

echo "✅ Xvfb running on $DISPLAY (${resolution}@${depth}dpi${dpi})"

# 🪟 Start a minimal WM (Openbox)
openbox-session >/tmp/openbox.log 2>&1 &
bg_pids+=("$!")

# 🔎 Optional info (no hard failure)
which glxinfo >/dev/null 2>&1 && glxinfo | grep -E "renderer|OpenGL" || echo "ℹ️ GLX info not available (software GL likely)"

# 🌀 Start Xpra desktop server with HTML5 client
# NOTE: xpra will expose an HTML5 client on the TCP port we bind (default 10000 here)
XPRA_PORT="${XPRA_PORT:-10000}"
XPRA_BIND="0.0.0.0:${XPRA_PORT}"

echo "🌀 Starting Xpra on $DISPLAY (HTML5: http://${XPRA_BIND}/)"
# --no-daemon to keep it in foreground (so the script stays attached)
xpra start "$DISPLAY" \
  --start-child=openbox-session \
  --bind-tcp="$XPRA_BIND" \
  --html=on \
  --no-daemon \
  --dbus-control=no \
  --dbus-launch='' \
  --dbus-proxy=no \
  --notifications=no \
  --opengl=no \
  --env=DISPLAY="$DISPLAY" \
  --dpi="$dpi" \
  --resize-display=yes \
  --min-size="${width}x${height}"  &
XPRA_PID=$!
bg_pids+=("$XPRA_PID")

# Health wait
for i in $(seq 1 30); do
  if pgrep -f "xpra .* ${DISPLAY}" >/dev/null; then
    break
  fi
  echo "⏳ Waiting for Xpra to be ready... ($i)"
  sleep 1
  if [ "$i" -eq 30 ]; then
    echo "❌ Xpra did not start properly" >&2
    exit 1
  fi
done

# Final status
echo "✅ Xpra HTML5 ready on http://${XPRA_BIND}/"

# Keep the script alive while xpra is running
wait "$XPRA_PID" || true

echo "🛑 Session ended."