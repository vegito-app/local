#! /usr/bin/env bash

set -euo pipefail

CONTAINER_NAME="application-backend"
PORTS_TO_WAIT_FOR=(8080)

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
${APPLICATION_BACKEND_DIR}/docker-compose-up.sh &
compose_pid=$! 

{
  for port in "${PORTS_TO_WAIT_FOR[@]}"; do
    until nc -z $CONTAINER_NAME $port; do
      echo "⏳ Waiting for $CONTAINER_NAME container on port $port..."
      sleep 1
    done
  done
  echo "✅ $CONTAINER_NAME container is healthy!"
  echo "You can access the application at http://localhost:8080"
} &
bg_pids+=($!)

# -- Wait for docker-compose to exit --
wait "$compose_pid"