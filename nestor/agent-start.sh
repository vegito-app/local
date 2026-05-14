#!/bin/bash

set -euo pipefail

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

# Exemple:
# ollama serve &
# bg_pids+=($!)

# Exemple:
# python3 /opt/nestor/agent.py &
# bg_pids+=($!)

if [ "${#bg_pids[@]}" -gt 0 ]; then
    wait "${bg_pids[@]}"
else
    exec sleep infinity
fi