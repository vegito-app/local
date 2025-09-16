#! /usr/bin/env bash

set -euo pipefail

CONTAINER_NAME="application-mobile"
PORTS_TO_WAIT_FOR=(5037 5900)

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

# Array to hold background job PIDs
bg_pids=() 

# Start docker-compose up in the background
${LOCAL_APPLICATION_MOBILE_DIR}/docker-compose-up.sh &
compose_pid=$! 

{
  for port in "${PORTS_TO_WAIT_FOR[@]}"; do
    until nc -z $CONTAINER_NAME $port; do
      echo "⏳ Waiting for $CONTAINER_NAME container on port $port..."
      sleep 1
    done
  done
  echo "✅ $CONTAINER_NAME container is healthy!"
  echo "🧩 Connect via ADB: adb connect localhost:5037"
  echo "🖥️  Connect via VNC: use localhost:5900"
} &
bg_pids+=($!)

# -- Wait for docker-compose to exit --
wait "$compose_pid"