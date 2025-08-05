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

openbox
