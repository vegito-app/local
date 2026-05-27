#!/bin/bash

set -euo pipefail

# Nettoyage du flag d'état à chaque arrêt
rm -f /tmp/.ai-agent-ready

bg_pids=()

kill_jobs() {
    rm -f /tmp/.ai-agent-ready
    echo "🧼 Cleaning up Ai services..."
    for pid in "${bg_pids[@]}"; do
        kill "$pid" 2>/dev/null || true
        wait "$pid" 2>/dev/null || true
    done
}

trap kill_jobs EXIT

echo "🤖 Starting Ai runtime..."

ollama serve &
ollama_pids=$!

# Create a ready flag file for healthchecks and other services to know when the AI agent is ready
echo "{\"status\":\"ready\",\"ts\":$(date +%s)}" > /tmp/.ai-agent-ready

echo "✅ Ai agent started successfully."

if [ ! $# -eq 0 ]; then
  "$@" &
  bg_pids+=("$!")
else
  echo "[entrypoint] No command passed, waiting ai agent to keep container alive"
fi

wait ${ollama_pids}