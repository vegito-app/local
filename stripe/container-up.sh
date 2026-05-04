#! /usr/bin/env bash

set -euo pipefail

CONTAINER_NAME="stripe"

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

docker_compose=${LOCAL_DOCKER_COMPOSE:-docker compose -f ${LOCAL_STRIPE_DIR}/docker-compose.yml}

echo "📱 Launching stripe-emulators compose in background..."
${LOCAL_STRIPE_DIR}/docker-compose-up.sh &
compose_pid=$!

# Start waiting for ports in a background subshell
{
  until ${docker_compose} exec stripe pgrep -f stripe >/dev/null; do
    echo "⏳ Waiting for $CONTAINER_NAME to start..."
    sleep 1
  done
  echo "✅ $CONTAINER_NAME is healthy on all ports!"
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
    echo "🥳 All stripe-emulators ports are ready!"
    exit_code=0
    break
  fi
  sleep 1
done

exit $exit_code
