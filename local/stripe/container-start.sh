#!/bin/bash
set -euo pipefail

STRIPE_LOG="/tmp/stripe.log"

bg_pids=()

cleanup() {
  trap - EXIT INT TERM

  echo "[entrypoint] Cleaning up background processes..."

  for pid in "${bg_pids[@]}"; do
    kill "$pid" 2>/dev/null || true
  done

  for pid in "${bg_pids[@]}"; do
    wait "$pid" 2>/dev/null || true
  done
}

trap cleanup EXIT
trap 'exit 130' INT
trap 'exit 143' TERM

echo "[entrypoint] Starting Stripe listener..."

: "${STRIPE_DEBUG_KEY:?STRIPE_DEBUG_KEY is required}"

stripe listen \
  --all-snapshot \
  --forward-to "${STRIPE_FORWARD_TO:-http://localhost:8888/webhooks/stripe}" \
  --api-key "${STRIPE_DEBUG_KEY}" \
  > "$STRIPE_LOG" 2>&1 &

stripe_pid=$!
bg_pids+=("$stripe_pid")

echo "[entrypoint] Waiting for Stripe webhook secret..."

LOCAL_STRIPE_WEBHOOK_SECRET=""

for i in $(seq 1 15); do

  if ! kill -0 "$stripe_pid" 2>/dev/null; then
    echo "[entrypoint] ERROR: Stripe CLI stopped unexpectedly"
    cat "$STRIPE_LOG"
    exit 1
  fi

  LOCAL_STRIPE_WEBHOOK_SECRET=$(
    grep -oE 'whsec_[A-Za-z0-9]+' "$STRIPE_LOG" | head -n1 || true
  )

  if [ -n "$LOCAL_STRIPE_WEBHOOK_SECRET" ]; then
    break
  fi

  sleep 1
done

if [ -z "$LOCAL_STRIPE_WEBHOOK_SECRET" ]; then
  echo "[entrypoint] ERROR: Stripe webhook secret timeout"
  cat "$STRIPE_LOG"
  exit 1
fi

echo "[entrypoint] Stripe webhook secret retrieved"

# Write environment files
umask 077

cat > /tmp/stripe_env.sh <<EOF
#!/bin/sh
export LOCAL_STRIPE_WEBHOOK_SECRET='$LOCAL_STRIPE_WEBHOOK_SECRET'
EOF

cat > ~/.stripe_env <<EOF
export LOCAL_STRIPE_WEBHOOK_SECRET='$LOCAL_STRIPE_WEBHOOK_SECRET'
EOF

touch ~/.profile

grep -qxF 'source ~/.stripe_env' ~/.profile \
  || echo 'source ~/.stripe_env' >> ~/.profile

echo "[entrypoint] Stripe environment configured"
echo "[entrypoint] Stripe listener ready"

tail -f "$STRIPE_LOG" &
bg_pids+=("$!")

# Keep the container alive while Stripe runs
wait "$stripe_pid"

echo "[entrypoint] Stripe listener stopped"