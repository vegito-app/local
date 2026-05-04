#!/bin/bash

set -euo pipefail

# 📌 List of PIDs of background processes
bg_pids=()

# 🧹 Function called at the end of the script to kill background processes
kill_jobs() {
    echo "🧼 Cleaning up background processes..."
    for pid in "${bg_pids[@]}"; do
        kill "$pid" || true
        wait "$pid" 2>/dev/null || true
    done
}

# 🚨 Register cleanup function to run on script exit

trap kill_jobs EXIT

echo "[entrypoint] Starting Stripe listener..."

# 🚨 Check that STRIPE_FORWARD_TO is set
: "STRIPE_FORWARD_TO is set to '$STRIPE_FORWARD_TO'"
: "STRIPE_DEBUG_KEY is set to '$STRIPE_DEBUG_KEY'"

stripe listen \
  --forward-to ${STRIPE_FORWARD_TO} \
  --api-key ${STRIPE_DEBUG_KEY} > /tmp/stripe.log 2>&1 &
bg_pids+=($!)

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

grep -qxF 'source ~/.stripe_env' ~/.bashrc || echo 'source ~/.stripe_env' >> ~/.bashrc
grep -qxF 'source ~/.stripe_env' ~/.profile || echo 'source ~/.stripe_env' >> ~/.profile

  echo "[entrypoint] Webhook secret set: $STRIPE_WEBHOOK_SECRET"
  echo "[entrypoint] Env written to /tmp/stripe_env.sh"
  echo "[entrypoint] Env also propagated globally via /etc/profile.d/stripe.sh"
fi

if [ $# -eq 0 ]; then
  echo "[entrypoint] No command passed, entering sleep infinity to keep container alive"
  wait "${bg_pids[@]}"
  echo "[entrypoint] All background processes have exited, container will stop now."
else
  echo "[entrypoint] Executing passed command: $*"
  exec "$@"
fi