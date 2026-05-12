#!/bin/bash

set -euo pipefail

source enable-nvidia-gl.sh

# Nettoyage du flag d'état à chaque arrêt
rm -f /tmp/.xdisplay-ready
# 📌 List of PIDs of background processes
bg_pids=()

# 🖥️ Default parameters
default_depth="24"
default_display_number=":1"
default_dpi="96"
default_framerate="60"
default_resolution="1920x1080"
default_wayland_socket="wayland-1"

resolution="${DISPLAY_RESOLUTION:-$default_resolution}"
depth="${DISPLAY_DEPTH:-$default_depth}"
dpi="${DISPLAY_DPI:-$default_dpi}"
display="${DISPLAY:-$default_display_number}"
framerate="${DISPLAY_FRAMERATE:-$default_framerate}"
wayland_socket="${WAYLAND_SOCKET:-$default_wayland_socket}"

# 🧹 Function called at the end of the script to kill background processes
kill_jobs() {
    rm -f /tmp/.xdisplay-ready
    echo "🧼 Cleaning up background processes..."

    for pid in "${bg_pids[@]}"; do
        kill "$pid" 2>/dev/null || true
        wait "$pid" 2>/dev/null || true
    done

    pkill -f -9 "Xwayland $display" || true
    pkill -f "weston.*${wayland_socket}" || true
    rm -rf /tmp/.X11-unix/X${display#*:}
    rm -rf /tmp/.X${display#*:}-lock
}

# 🚨 Register cleanup function to run on script exit
trap kill_jobs EXIT

WAYLAND_DISPLAY_NAME=${WAYLAND_DISPLAY_NAME:-$default_wayland_socket}
DISPLAY_RESOLUTION=${DISPLAY_RESOLUTION:-$default_resolution}
DISPLAY_DPI=${DISPLAY_DPI:-$default_dpi}

# -------------------------------------------------------------------
# Weston startup
# -------------------------------------------------------------------

export WAYLAND_DISPLAY="${WAYLAND_DISPLAY_NAME}"

mkdir -p /tmp/.X11-unix

echo "🚀 Starting Weston headless GPU compositor..."

cat >/tmp/weston.ini <<EOF
[core]
backend=headless-backend.so
idle-time=0

[shell]
panel-position=none
locking=false
EOF

# 🖥️ Resolution personnalisé
# 🔧 Extraction robuste de la largeur et hauteur
width="${resolution%x*}"    # Supprime 'x*' à partir de la fin
height="${resolution#*x}"   # Supprime '*x' depuis le début

# 🚀 Starting Weston compositor with NVIDIA OpenGL
unset EGL_PLATFORM
unset LIBGL_ALWAYS_SOFTWARE

echo "🚀 Starting Weston compositor with NVIDIA OpenGL..."
weston \
  --backend=headless-backend.so \
  --use-gl \
  --socket="${wayland_socket}" \
  --config=/tmp/weston.ini \
  --width="${width}" \
  --height="${height}" \
    > /tmp/weston.log 2>&1 &

weston_pid=$!
bg_pids+=("${weston_pid}")

timeout_weston=60

for i in $(seq 1 ${timeout_weston}); do
    if [ -S "${XDG_RUNTIME_DIR}/${WAYLAND_DISPLAY}" ]; then
        break
    fi

    echo "⏳ Waiting for Weston Wayland socket..."
    sleep 1
done

if [ ! -S "${XDG_RUNTIME_DIR}/${WAYLAND_DISPLAY}" ]; then
    echo "❌ Weston socket not available."
    echo "----- WESTON LOG -----"
    cat /tmp/weston.log || true
    exit 1
fi

echo "✅ Weston started successfully."

# -------------------------------------------------------------------
# Manual XWayland startup
# -------------------------------------------------------------------

export DISPLAY=${display}

rm -f /tmp/.X11-unix/X${display#*:}
rm -f /tmp/.X${display#*:}-lock

echo "🚀 Starting manual XWayland EGLStream server..."

# 🖥️ XWayland

export DISPLAY=${display}

Xwayland ${DISPLAY} \
    +extension GLX \
    +extension RANDR \
    +extension RENDER \
    +extension COMPOSITE \
    > /tmp/xwayland.log 2>&1 &

xwayland_pid=$!
bg_pids+=("${xwayland_pid}")

until [ -S "$XDG_RUNTIME_DIR/$WAYLAND_DISPLAY" ]; do
    echo "⏳ Waiting for Weston socket..."
    sleep 1
done

until glxinfo -B >/dev/null 2>&1; do
    echo "⏳ Waiting for XWayland GLX..."
    sleep 1
done

echo "✅ Weston/XWayland started successfully"

echo "🔍 OpenGL renderer"
glxinfo -B | grep -E "OpenGL vendor|OpenGL renderer|OpenGL version" || echo "⚠️ OpenGL info not available"

echo "✅ XWayland started successfully"

# -------------------------------------------------------------------
# GPU validation
# -------------------------------------------------------------------

if command -v glxinfo >/dev/null 2>&1; then
    echo "🔍 XWayland GLX capabilities"
    DISPLAY=:0 glxinfo -B || true
fi

export WAYLAND_DISPLAY="${WAYLAND_DISPLAY}"
export WAYLAND_DEBUG=0

WAYVNC_PORT=${WAYVNC_PORT:-5901}

if command -v weston-terminal >/dev/null 2>&1; then
    echo "🖥️ Launching weston-terminal..."
    weston-terminal > /tmp/weston-terminal.log 2>&1 &
    bg_pids+=("$!")
elif command -v foot >/dev/null 2>&1; then
    echo "🖥️ Launching foot terminal..."
    foot > /tmp/foot.log 2>&1 &
    bg_pids+=("$!")
else
    echo "⚠️ No Wayland terminal found (weston-terminal or foot missing)."
fi

echo "🔍 Weston GPU capabilities"

grep -E "GL renderer|GL vendor|GL version" /tmp/weston.log || true

echo "🖥️ Weston headless GPU session ready"
echo "📺 XWayland display available on DISPLAY=:0"
echo "✅ GPU compositor active"
echo "ℹ️ Launch Wayland-native applications inside this session"

ENABLE_AUDIO="${ENABLE_AUDIO:-0}"
if [ "$ENABLE_AUDIO" = "1" ]; then
    echo "🔊 Audio enabled (xpra managed)"
    XPRA_AUDIO_FLAGS="--speaker=on --microphone=off"
else
    echo "🔇 Audio disabled"
    XPRA_AUDIO_FLAGS="--speaker=off --microphone=off"
fi

DISPLAY_MODE="${DISPLAY_MODE:-xpra}"

if [ "$DISPLAY_MODE" = "xpra" ]; then

echo "🌀 Starting Xpra on ${DISPLAY:-$display}..."

unset XPRA_SERVER_SOCKET
unset XPRA_SESSION_DIR

if nvidia-smi >/dev/null 2>&1; then
if command -v nvidia-smi >/dev/null 2>&1 && nvidia-smi >/dev/null 2>&1; then
    echo "✅ NVIDIA NVENC available"
    XPRA_VIDEO_ENCODERS_FLAGS="--video-encoders=${XPRA_VIDEO_ENCODERS:-nvenc}" 
else
    echo "ℹ️ NVIDIA NVENC unavailable, using default xpra encoders"
fi
fi

xpra start "${DISPLAY:-$display}" \
    --use-display \
    --resize-display=no \
    --desktop-scaling=auto \
    --dpi="$dpi" \
    --env=DISPLAY="${DISPLAY:-$display}" \
    --env=XPRA_NVENC_ENABLED=1 \
    --quality="${XPRA_QUALITY:-80}" \
    --min-quality="${XPRA_MIN_QUALITY:-30}" \
    --speed="${XPRA_SPEED:-70}" \
    --min-speed="${XPRA_MIN_SPEED:-30}" \
    --encoding="${XPRA_ENCODING:-h264}" \
    ${XPRA_VIDEO_ENCODERS_FLAGS} \
    --html=on \
    --socket-dir="$XPRA_SOCKET_DIR" \
    --socket-dirs="$XPRA_SOCKET_DIR" \
    --bind-tcp=0.0.0.0:5901 \
    ${XPRA_AUDIO_FLAGS} \
    --no-daemon \
    --no-mdns \
    --webcam=no &
    display_pid=$!

    XPRA_SOCKET="$XPRA_SOCKET_DIR/$(hostname)-${display#:}"
    export XPRA_SERVER_SOCKET="$XPRA_SOCKET"
    
    until [ -S "$XPRA_SOCKET" ]; do
        echo "⏳ Waiting for xpra socket..."
        sleep 1
    done
    echo "🌀 Xpra started successfully on ${DISPLAY:-$display}."
    for i in $(seq 1 10); do
    if pactl info >/dev/null 2>&1; then
        echo "🔊 PulseAudio ready"
        break
    fi

    echo "⏳ Waiting for PulseAudio..."
    sleep 1
done

echo "$GBM_BACKEND"
echo "$__GLX_VENDOR_LIBRARY_NAME"
echo "$__EGL_VENDOR_LIBRARY_FILENAMES"

glxinfo -B | grep -Ei "vendor|renderer"

xpra info | grep -Ei "nvenc|device_count|gpu.encodings"

elif [ "$DISPLAY_MODE" = "vnc" ]; then

    echo "🌀 Starting x11vnc..."
    echo "🌀 Starting x11vnc on $display..."
    x11vnc -display "$display" -nopw -noxdamage -shared -forever -repeat &
    display_pid=$!

    until pgrep -f "x11vnc -display $display" > /dev/null; do 
    echo "⏳ Waiting for x11vnc to start on $display...";
    sleep 1; 
    done
    echo "✅ x11vnc running on $display → http://localhost:5900/ 🖥️"
    
    openbox-session &
    bg_pids+=("$!")

else
    echo "⚠️ Invalid display mode. Please choose 'xpra' or 'vnc'."
fi

# Création d'un flag indiquant que tout le display est prêt
echo "{\"status\":\"ready\",\"ts\":$(date +%s)}" > /tmp/.xdisplay-ready

wait "$display_pid" || true

echo "🛑 Session ended."
