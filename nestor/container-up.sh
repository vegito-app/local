#! /usr/bin/env bash

set -euo pipefail

CONTAINER_NAME="nestor"

PORTS_TO_WAIT_FOR=${LOCAL_NESTOR_PORTS_TO_WAIT_FOR:-"2375 5901"}

# Convert space-separated string to bash array
read -ra PORTS <<< "$PORTS_TO_WAIT_FOR"

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

docker_compose=${LOCAL_DOCKER_COMPOSE:-docker compose -f ${LOCAL_NESTOR_DIR}/docker-compose.yml}

echo "📱 Launching nestor compose in background..."

${docker_compose} up nestor 2>&1 &
compose_pid=$!

# Start waiting for ports in a background subshell
{
  for port in "${PORTS[@]}"; do
    until nc -z $CONTAINER_NAME $port; do
      echo "⏳ Waiting for $CONTAINER_NAME on port $port..."
      sleep 1
    done
  done
  echo "✅ $CONTAINER_NAME is healthy on all ports!"
} &
wait_pid=$!

export DOCKER_HOST=tcp://nestor:23755

until docker info >/dev/null 2>&1; do echo waiting Nestor startup ; sleep 1 ; done

docker info

# Start waiting for ports in a background subshell
{
  until ${docker_compose} exec nestor pgrep -f agent-start >/dev/null; do
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
    echo "🥳 All nestor ports are ready!"
    exit_code=0
    break
  fi
  sleep 1
done

exit $exit_code
