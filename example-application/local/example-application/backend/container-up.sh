#! /usr/bin/env bash

set -euo pipefail

CONTAINER_NAME="application-backend"
PORTS_TO_WAIT_FOR=(8080)

bg_pids=()
compose_pid=
wait_pid=

# Function to kill background jobs (waiter only)
kill_jobs() { 
    echo "🧹 Cleaning up background jobs..." 
    if [[ -n "${wait_pid:-}" ]]; then
      kill "$wait_pid" 2>/dev/null || true
      wait "$wait_pid" 2>/dev/null || true
    fi
}
trap kill_jobs EXIT

# Start docker-compose up in the background
echo "🚢 Launching backend compose in background..."
${APPLICATION_BACKEND_DIR}/docker-compose-up.sh &
compose_pid=$!

# Start waiting for ports in a background subshell
{
  for port in "${PORTS_TO_WAIT_FOR[@]}"; do
    until nc -z $CONTAINER_NAME $port; do
      echo "⏳ Waiting for $CONTAINER_NAME on port $port..."
      sleep 1
    done
  done
  echo "✅ $CONTAINER_NAME is healthy on all ports! Access: http://localhost:8080"
} &
wait_pid=$!

# 🏁 Wait for either compose or wait-loop to finish
set +e
exit_code=0
while :; do
  if ! kill -0 $compose_pid 2>/dev/null; then
    echo "❌ Compose process exited prematurely!"
    exit_code=1
    break
  fi
  if ! kill -0 $wait_pid 2>/dev/null; then
    echo "🥳 All application-backend ports are ready!"
    exit_code=0
    break
  fi
  sleep 1
done

exit $exit_code
