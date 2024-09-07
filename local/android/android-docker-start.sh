#!/bin/bash

set -eu

# List to hold background job PIDs
bg_pids=()

# Function to kill background jobs when script ends
kill_jobs() {
    echo "Killing background jobs"
    for pid in "${bg_pids[@]}"; do
        kill "$pid"
        wait "$pid" 2>/dev/null
    done
}

# Trap to call kill_jobs on script exit
trap kill_jobs EXIT

# 
socat TCP-LISTEN:5901,fork,reuseaddr TCP:vnc-android-studio:5900 > /tmp/socat-vnc-android-studio-5900.log 2>&1 &
bg_pids+=("$!")

docker compose up vnc-android-studio 2>&1
