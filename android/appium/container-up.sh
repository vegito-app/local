#! /usr/bin/env bash

set -euo pipefail

CONTAINER_NAME=${LOCAL_ANDROID_APPIUM_CONTAINER_NAME:-"android-appium"}
PORTS_TO_WAIT_FOR=(5900 5901 5037 4723)
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

echo "📱 Launching android-appium compose in background..."
${LOCAL_ANDROID_APPIUM_DIR}/docker-compose-up.sh &
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
    echo "🥳 All android-appium ports are ready!"
    exit_code=0
    break
  fi
  sleep 1
done

exit $exit_code
