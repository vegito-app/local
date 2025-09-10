#!/bin/sh

set -euo pipefail

vault server -dev -dev-root-token-id ${VAULT_DEV_ROOT_TOKEN_ID} &

until vault status -format=json | jq -e '.sealed' | grep -q 'false'; do
  echo "Vault is sealed, waiting..."
  sleep 1
done

vault audit enable file file_path=${VAULT_AUDIT}/vault_audit.log

vault secrets enable transit || echo "transit engine already enabled"

vault policy write backend-application ./vault-policies.hcl

vault auth enable gcp || echo "gcp auth already enabled"

vault write auth/gcp/role/backend-application \
  type="gce" \
  policies="backend-application" \
  bound_service_accounts="*" \
  project_id="your-gcp-project-id"

echo ✅ Success ! Initialized vault for backend-application.