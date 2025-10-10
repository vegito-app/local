#!/bin/sh

set -euo pipefail


vault secrets enable transit || echo "transit engine already enabled"

vault policy write backend-application ./vault-policies.hcl

vault auth enable gcp || echo "gcp auth already enabled"

vault write auth/gcp/role/backend-application \
  type="gce" \
  policies="backend-application" \
  bound_service_accounts="*" \
  project_id="your-gcp-project-id"

echo "✅ Success ! Initialized vault for backend-application."