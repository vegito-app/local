#!/bin/bash

set -euo pipefail

# Nettoyage du flag d'état à chaque arrêt
rm -f /tmp/.ai-agent-ready

bg_pids=()
ollama_pid=

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

if [ -n "${OLLAMA_HOST:-}" ]; then
    echo "Using remote Ollama ${OLLAMA_HOST}"
else
    echo "Starting local Ollama"
    ollama serve &
    ollama_pid=$!
    export OLLAMA_HOST=http://127.0.0.1:11434
fi

# Create a ready flag file for healthchecks and other services to know when the AI agent is ready
echo "{\"status\":\"ready\",\"ts\":$(date +%s)}" > /tmp/.ai-agent-ready

echo "✅ Ai agent started successfully."

if [ ! -z "${ollama_pid}" ];then
  wait "${ollama_pid}"
  echo "Ollama process exited with code $?"
elif [ "${#bg_pids[@]}" -gt 0 ]; then
  echo "Waiting for background processes to finish..."
  wait "${bg_pids[@]}"
fi