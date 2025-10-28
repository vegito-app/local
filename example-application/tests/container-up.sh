#!/bin/bash

set -euo pipefail

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

docker_compose=${LOCAL_DOCKER_COMPOSE:-"docker compose -f ${VEGITO_MOBILE_DIR}/docker-compose.yml"}
exec $docker_compose up example-application-tests \
  --exit-code-from "example-application-tests" \
  --abort-on-container-exit \
  --build \
  --remove-orphans \
  --force-recreate
