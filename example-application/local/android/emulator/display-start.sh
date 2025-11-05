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


# Boucle d'attente pour permettre à xvfb de démarrer
until xdpyinfo -display ${display} > /dev/null 2>&1; do 
    echo Waiting X display frame buffer
    sleep 1
done

# Lancer openbox en arrière-plan avec gestion d'erreur
echo "🚀 Starting Openbox window manager..."
openbox &
openbox_pid=$!
bg_pids+=("$openbox_pid")

# Boucle d'attente pour permettre à openbox de démarrer
until pgrep -f "openbox" > /dev/null; do 
  echo "⏳ Waiting for Openbox to start...";
  sleep 1; 
done
echo "✅ Openbox started successfully."

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
  --use-display  \
  --bind-tcp=0.0.0.0:5901   \
  --dbus-control=no \
  --dbus-launch='' \
  --dbus-proxy=no \
  --desktop-scaling=auto \
  --dpi="$dpi"   \
  --env=DISPLAY="$display" \
  --html=on \
  --min-size="$resolution" \
  --no-daemon   \
  --no-mdns   \
  --notifications=no \
  --resize-display=yes \
  --webcam=no &

xpra_pid=$!

bg_pids+=("$xpra_pid")

# Boucle d'attente pour permettre à xpra de démarrer
until pgrep -f "xpra start-desktop $display" > /dev/null; do 
  echo "⏳ Waiting for Xpra to start on $display...";
  sleep 1; 
done
echo "🌀 Xpra started successfully on $display with Openbox session."

# Garder le script en vie
echo "🖥️  Display server is ready"
wait "$x11vnc_bg_pid" "$xpra_pid" || true
echo "🛑 Session ended."