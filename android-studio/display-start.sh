#!/bin/bash

set -eu

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

default_resolution=1440x900

# Utiliser la variable d'environnement si elle existe, sinon utiliser la valeur par défaut
resolution=${DISPLAY_RESOLUTION:-$default_resolution}

# Lancez xvfb en arrière-plan
Xvfb ${DISPLAY} -nolisten tcp -ac -screen 0, ${resolution}x24 &
bg_pids+=("$!")


# Boucle d'attente pour permettre à xvfb de démarrer
until xdpyinfo -display ${DISPLAY} > /dev/null 2>&1; do 
    echo Waiting X display frame buffer
    sleep 1
done

# x11vnc -display ${DISPLAY} -nopw -noxdamage -shared -forever -repeat -ncache 10 -ncache_cr &
x11vnc -display ${DISPLAY} -nopw -noxdamage -shared -forever -repeat &
bg_pids+=("$!")

# Register cleanup function to run on script exit
trap kill_jobs EXIT

# Lancer openbox en arrière-plan avec gestion d'erreur
echo "🚀 Starting Openbox window manager..."
openbox &
openbox_pid=$!
bg_pids+=("$openbox_pid")

# Attendre qu'openbox démarre (avec timeout)
openbox_timeout=30
openbox_counter=0
openbox_started=false

while [ $openbox_counter -lt $openbox_timeout ]; do
    if ps -p $openbox_pid > /dev/null 2>&1; then
        echo "✅ Openbox session started successfully"
        openbox_started=true
        break
    fi
    echo "⏳ Waiting for Openbox session to start... ($openbox_counter/$openbox_timeout)"
    sleep 1
    openbox_counter=$((openbox_counter + 1))
done

if [ "$openbox_started" = "false" ]; then
    echo "❌ Failed to start Openbox session within $openbox_timeout seconds"
    echo "🔄 Trying to start a minimal window manager fallback..."
    
    # Fallback: utiliser twm si openbox ne fonctionne pas
    if command -v twm > /dev/null 2>&1; then
        twm &
        bg_pids+=("$!")
        echo "✅ Started TWM as fallback window manager"
    else
        echo "⚠️  No fallback window manager available, continuing without WM"
    fi
fi

# Garder le script en vie
echo "🖥️  Display server is ready"
wait
