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

export DISPLAY="${display}"

# Lancez xvfb en arrière-plan
Xvfb "${display}" -nolisten tcp -ac -screen 0, ${resolution}x24 &
bg_pids+=("$!")

timeout_xvfb=60
for i in $(seq 1 $timeout_xvfb); do
    if xdpyinfo -display "${display}" > /dev/null 2>&1; then
        break
    fi
    echo Waiting X display frame buffer
    sleep 1
done
if ! xdpyinfo -display "${display}" > /dev/null 2>&1; then
    echo "❌ Timeout waiting for X display ${display}."
    exit 1
fi

DISPLAY_MODE="${DISPLAY_MODE:-xpra}"

if [ "$DISPLAY_MODE" = "xpra" ]; then
 
  xpra-start.sh &
  display_pid="$!"

elif [ "$DISPLAY_MODE" = "vnc" ]; then
 
    vnc-start.sh &
    display_pid="$!"

    openbox-session &
    bg_pids+=("$!")

else
    echo "⚠️ Invalid display mode. Please choose 'xpra' or 'vnc'."
fi

# Création d'un flag indiquant que tout le display est prêt
echo "{\"status\":\"ready\",\"ts\":$(date +%s)}" > /tmp/.xdisplay-ready
# Garder le script en vie
echo "🖥️  Display server is ready"
wait "$display_pid" || true
echo "🛑 Session ended."