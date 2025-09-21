#! /usr/bin/env bash

set -uo pipefail

CONTAINER_NAME="clarinet-devnet"

CLARINET_DEVVNET_ROOTLESS_DOCKER_SOCKET=2376
BITCOIND_PORTS=(18443 18444)
POSTGRES_PORTS=5432
STACKS_API_PORTS=3999
STACKS_NODE_PORTS=(20443 20444)
STACKS_EXPLORER_PORTS=8000

PORTS_TO_WAIT_FOR=(
  ${CLARINET_DEVVNET_ROOTLESS_DOCKER_SOCKET}
  ${BITCOIND_PORTS[@]}
  ${POSTGRES_PORTS}
  ${STACKS_API_PORTS}
  ${STACKS_NODE_PORTS[@]}
  ${STACKS_EXPLORER_PORTS}
)

pids=()
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

echo "📱 Launching clarinet-devnet compose in background..."
${LOCAL_CLARINET_DEVNET_DIR}/docker-compose-up.sh &
compose_pid=$!

# Start waiting for ports in a background subshell
{
  for port in "${PORTS_TO_WAIT_FOR[@]}"; do
    until nc -z $CONTAINER_NAME $port; do
      echo "⏳ Waiting for $CONTAINER_NAME on port $port..."
      sleep 1
    done
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
    echo "🥳 All clarinet-devnet ports are ready!"
    exit_code=0
    break
  fi
  sleep 1
done

exit $exit_code
