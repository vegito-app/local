#!/bin/bash

set -euo pipefail

SOCAT_MAPS=(
  "8080:8080:http"  # Backend HTTP
)

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

# -- Start socat port forwarders --
for map in "${SOCAT_MAPS[@]}"; do
  IFS=":" read -r local remote label <<< "$map"
  socat TCP-LISTEN:$local,fork,reuseaddr TCP:application-backend:$remote \
    >> "/tmp/socat-application-backend-${label}-${remote}.log" 2>&1 &
  bg_pids+=("$!")
done

docker_compose=${LOCAL_DOCKER_COMPOSE:-"docker compose -f ${VEGITO_MOBILE_DIR}/docker-compose.yml"}
exec $docker_compose up example-application-backend
