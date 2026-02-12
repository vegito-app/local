#! /usr/bin/env bash

set -euo pipefail

CONTAINER_NAME="firebase-emulators"
PORTS_TO_WAIT_FOR=(4000 5001 8085 8090 9099 9000 9199)

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

echo "📱 Launching firebase-emulators compose in background..."
${LOCAL_FIREBASE_EMULATORS_DIR}/docker-compose-up.sh &
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

  echo "📦 Initializing Pub/Sub topics and subscriptions..."
  make \
    LOCAL_FIREBASE_EMULATORS_PUBSUB_VEGETABLE_IMAGES_VALIDATED_SUBSCRIPTIONS="${LOCAL_FIREBASE_EMULATORS_PUBSUB_VEGETABLE_IMAGES_VALIDATED_SUBSCRIPTIONS}" \
    LOCAL_FIREBASE_EMULATORS_PUBSUB_VEGETABLE_IMAGES_CREATED_TOPIC=${LOCAL_FIREBASE_EMULATORS_PUBSUB_VEGETABLE_IMAGES_CREATED_TOPIC} \
    local-firebase-emulators-pubsub-init >&2
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
    echo "🥳 All firebase-emulators ports are ready!"
    exit_code=0
    break
  fi
  sleep 1
done

exit $exit_code


