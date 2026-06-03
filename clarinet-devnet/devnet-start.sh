#!/bin/bash

set -euo pipefail


# Nettoyage du flag d'état à chaque arrêt
rm -f /tmp/.clarinet-devnet-runtime-ready

bg_pids=()

kill_jobs() {
    echo "🧼 Cleaning up Clarinet Devnet services..."
    for pid in "${bg_pids[@]}"; do
        kill "$pid" 2>/dev/null || true
        wait "$pid" 2>/dev/null || true
    done
}

trap kill_jobs EXIT

echo "🤖 Starting Clarinet Devnet runtime..."

debian-dind-rootless-start.sh &
bg_pids+=("$!")

echo "✅ Clarinet Devnet dockerd rootless started successfully."

docker rm -f `docker ps -aq --filter name=devnet` 2>/dev/null
docker network rm -f `docker network ls -q --filter name=devnet` 2>/dev/null || true

clarinet devnet start --no-dashboard

# Create a ready flag file for healthchecks and other services to know when the AI agent is ready
echo "{\"status\":\"ready\",\"ts\":$(date +%s)}" > /tmp/.clarinet-devnet-runtime-ready

echo "✅ Clarinet Devnet runtime started successfully."

sleep infinity