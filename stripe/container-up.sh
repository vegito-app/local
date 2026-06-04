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

# Wait for Stripe CLI to output the webhook secret
echo "[entrypoint] Waiting for Stripe webhook secret..."
for i in $(seq 1 10); do
  if grep -q 'whsec_' /tmp/stripe.log; then
    break
  fi
  sleep 1
done

STRIPE_WEBHOOK_SECRET=$(grep -o 'whsec_[^ ]*' /tmp/stripe.log | head -n1 || true)
if [ -z "${STRIPE_WEBHOOK_SECRET}" ]; then
  echo "[entrypoint] WARNING: could not retrieve Stripe webhook secret"
else
  # Write env file for manual sourcing
  cat <<EOF > /tmp/stripe_env.sh
#!/bin/sh
export STRIPE_WEBHOOK_SECRET=$STRIPE_WEBHOOK_SECRET
EOF

  cat <<EOF > ~/.stripe_env
export STRIPE_WEBHOOK_SECRET=$STRIPE_WEBHOOK_SECRET
EOF

grep -qxF 'source ~/.stripe_env' ~/.profile || echo 'source ~/.stripe_env' >> ~/.profile

  echo "[entrypoint] Webhook secret set: $STRIPE_WEBHOOK_SECRET"
  echo "[entrypoint] Env written to /tmp/stripe_env.sh"
  echo "[entrypoint] Env also propagated globally via /etc/profile.d/stripe.sh"
  
  # Write env file for manual sourcing
  echo "STRIPE_WEBHOOK_SECRET=${STRIPE_WEBHOOK_SECRET}" > ${LOCAL_STRIPE_DIR}/.env
fi
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
