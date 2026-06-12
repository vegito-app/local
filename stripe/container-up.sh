#! /usr/bin/env bash

set -euo pipefail

CONTAINER_NAME=${LOCAL_STRIPECONTAINER_NAME:-"stripe"}

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

$docker_compose rm --force --stop stripe

echo "📱 Launching stripe-emulators compose in background..."
${LOCAL_STRIPE_DIR}/docker-compose-up.sh &
compose_pid=$!

docker_compose exec stripe -it bash -c "\
for i in $(seq 1 100); do 
  if echo \"$LOCAL_STRIPE_WEBHOOK_SECRET\" | grep -q 'whsec_' ; then
    break
  fi
  sleep 1
done
"