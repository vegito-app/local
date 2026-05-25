#!/bin/bash

set -euo pipefail


# Nettoyage du flag d'état à chaque arrêt
rm -f /tmp/.nestor-agent-ready

bg_pids=()

kill_jobs() {
    echo "🧼 Cleaning up Nestor services..."
    for pid in "${bg_pids[@]}"; do
        kill "$pid" 2>/dev/null || true
        wait "$pid" 2>/dev/null || true
    done
}

trap kill_jobs EXIT

echo "🤖 Starting Nestor runtime..."

desktop-x-display-start.sh &
bg_pids+=("$!")

debian-dind-rootless-start.sh &
bg_pids+=("$!")

# ⚡ Start AI runtime in background
ai-runtime-start.sh &
bg_pids+=("$!")

# Create a ready flag file for healthchecks and other services to know when the AI agent is ready
echo "{\"status\":\"ready\",\"ts\":$(date +%s)}" > /tmp/.nestor-agent-ready

echo "✅ Nestor agent started successfully."

# Exemple:
# python3 /opt/nestor/agent.py &
# bg_pids+=($!)
sleep infinity