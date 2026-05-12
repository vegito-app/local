#!/bin/bash

set -euo pipefail

# Nettoyage du flag d'état à chaque arrêt
rm -f /tmp/.xdisplay-ready

# 📌 List of PIDs of background processes
bg_pids=()

# 🧹 Function called at the end of the script to kill background processes
kill_jobs() {
    rm -f /tmp/.xdisplay-ready
    echo "🧼 Cleaning up background processes..."
    for pid in "${bg_pids[@]}"; do
        kill "$pid" || true
        wait "$pid" 2>/dev/null || true
    done
}

# Register cleanup function to run on script exit
trap kill_jobs EXIT

# 🖥️ Default parameters
default_display_number=":1"
default_dpi="96"
default_resolution="1920x1080"

# Utiliser la variable d'environnement si elle existe, sinon utiliser la valeur par défaut
display=${DISPLAY:-$default_display_number}
dpi=${DISPLAY_DPI:-$default_dpi}
resolution=${DISPLAY_RESOLUTION:-$default_resolution}

# Lancez xvfb en arrière-plan
Xvfb ${display} -nolisten tcp -ac -screen 0, ${resolution}x24 &
bg_pids+=("$!")

timeout_xvfb=60
for i in $(seq 1 $timeout_xvfb); do
    if xdpyinfo -display ${display} > /dev/null 2>&1; then
        break
    fi
    echo Waiting X display frame buffer
    sleep 1
done
if ! xdpyinfo -display ${display} > /dev/null 2>&1; then
    echo "❌ Timeout waiting for X display ${display}."
    exit 1
fi

# Lancer x11vnc en arrière-plan avec gestion d'erreur
echo "🌀 Starting x11vnc on $display with Openbox session..."
x11vnc -display "$display" -nopw -noxdamage -shared -forever -repeat &
x11vnc_bg_pid=$!
bg_pids+=("$x11vnc_bg_pid")

# Boucle d'attente pour permettre à x11vnc de démarrer
until pgrep -f "x11vnc -display $display" > /dev/null; do 
  echo "⏳ Waiting for x11vnc to start on $display...";
  sleep 1; 
done
echo "✅ x11vnc running on $display → http://localhost:5900/ 🖥️"

# Lancer xpra en arrière-plan avec gestion d'erreur
echo "🌀 Starting Xpra on $display with Openbox session..."
xpra start-desktop "$display" \
  --use-display \
  --start-child=openbox-session \
  --exit-with-children \
  --bind-tcp=0.0.0.0:5901 \
  --dbus-control= \
  --dbus-launch \
  --dbus-proxy= \
  --desktop-scaling= \
  --dpi="$dpi" \
  --env=DISPLAY="$display \
  --socket-dir="$XPRA_SOCKET_DIR" \
  --socket-dirs="$XPRA_SOCKET_DIR" \
  --html=on \
  --min-size="$resolution \
  --no-daemon \
  --no-mdns \
  --notifications= \
  --resize-display= \
  --webcam= &

xpra_pid=$!

XPRA_SOCKET="$XPRA_SOCKET_DIR/$(hostname)-${display#:}"
export XPRA_SERVER_SOCKET="$XPRA_SOCKET"

until [ -S "$XPRA_SOCKET" ]; do
    echo "⏳ Waiting for xpra socket..."
    sleep 1
done
echo "🌀 Xpra started successfully on ${DISPLAY:-$display} with Openbox session."

bg_pids+=("$xpra_pid")  

# Boucle d'attente pour permettre à xpra de démarrer
until pgrep -f "xpra start-desktop $display" > /dev/null; do 
  echo "⏳ Waiting for Xpra to start on $display...";
  sleep 1; 
done
echo "🌀 Xpra started successfully on $display with Openbox session."

# Création d'un flag indiquant que tout le display est prêt
echo "{\"status\":\"ready\",\"ts\":$(date +%s)}" > /tmp/.xdisplay-ready
# Garder le script en vie
echo "🖥️  Display server is ready"
wait "$x11vnc_bg_pid" "$xpra_pid" || true
echo "🛑 Session ended."