#! /usr/bin/env bash

set -euo pipefail

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

echo "📱 Launching stripe-emulators compose in background..."

docker_compose=${LOCAL_DOCKER_COMPOSE:-docker compose -f ${LOCAL_STRIPE_DIR}/docker-compose.yml}

stripe_container_name=${LOCAL_STRIPE_CONTAINER_NAME:-"stripe"}

${docker_compose} up $stripe_container_name 2>&1 &
compose_pid=$!

docker_compose_stripe_exec="$docker_compose exec -it $stripe_container_name"

echo "⏳ Starting to Wait for stripe-emulators container..."

until $docker_compose_stripe_exec bash -c "
set -euo pipefail
echo \"⏳ Waiting for stripe-emulators webhook secret...\"
for i in \$(seq 1 100); do
  echo \"⏳ Waiting for stipe webhook secret...\"
  if grep -q 'whsec_' /tmp/stripe.log; then
    break
  fi
  sleep 1
done
" : ; do
echo "⏳ Waiting for stripe-emulators container..." ;
sleep 1 ; done

VEGITO_STRIPE_WEBHOOK_SECRET=$($docker_compose_stripe_exec bash -c "
grep -o 'whsec_[^ ]*' /tmp/stripe.log | head -n1 || true
")

if [ -z "${VEGITO_STRIPE_WEBHOOK_SECRET}" ]; then
  echo "❌ Could not retrieve stripe-emulators webhook secret"
  exit 1
fi

echo "VEGITO_STRIPE_WEBHOOK_SECRET=${VEGITO_STRIPE_WEBHOOK_SECRET}" > ${LOCAL_STRIPE_DIR}/.env

echo "✅ stripe-emulators webhook secret is ready!"