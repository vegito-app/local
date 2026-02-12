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

trap kill_jobs EXIT

vault server -dev -dev-root-token-id=${VAULT_DEV_ROOT_TOKEN_ID} 2>&1 | tee /tmp/vault.log &
bg_pids+=($!)

until curl -s "$VAULT_ADDR/v1/sys/seal-status" | jq -r '.sealed' | grep -q 'false'; do
  curl -s "$VAULT_ADDR/v1/sys/seal-status" || true
  echo "Vault is sealed, waiting..."
  sleep 1
done

echo "✅ Vault is unsealed and ready."

VAULT_AUDIT=${VAULT_AUDIT:-${PWD:-/workspaces}/.containers/vault/audit}

if [ "${VAULT_AUDIT_INIT:-false}" = "true" ]; then
  echo "📁 Vault audit logs will be stored in: ${VAULT_AUDIT}/vault_audit.log"
  mkdir -p ${VAULT_AUDIT}
  vault audit enable file file_path=${VAULT_AUDIT}/vault_audit.log
fi

if [ $# -eq 0 ]; then
  wait "${bg_pids[@]}"
else
  exec "$@"
fi