#!/bin/sh

set -euo pipefail

echo "🎫 Récupération du token ADC via gcloud..."

TOKEN=$(cat /etc/vault/secrets/access_token/access_token)  # Correction de la parenthèse manquante

PROJECT_ID="moov-438615"
SERVICE_ACCOUNT="vault-tf-apply@${PROJECT_ID}.iam.gserviceaccount.com"
AUDIENCE="http://localhost:8210/vault/vault-tf-apply"
EXPIRATION_SECONDS=300

NOW=$(date +%s)
EXP=$((NOW + EXPIRATION_SECONDS))

JWT_PAYLOAD=$(jq -n \
  --arg aud "$AUDIENCE" \
  --arg iss "$SERVICE_ACCOUNT" \
  --arg sub "$SERVICE_ACCOUNT" \
  --argjson iat "$NOW" \
  --argjson exp "$EXP" \
  '{aud: $aud, iss: $iss, sub: $sub, iat: $iat, exp: $exp}')

TEMP_FILE=$(mktemp)
echo "$JWT_PAYLOAD" > "$TEMP_FILE"

echo "🔐 Signing JWT via gcloud..."
SIGNED_JWT=$(gcloud iam service-accounts sign-jwt \
  --iam-account="$SERVICE_ACCOUNT" \
  "$TEMP_FILE" /dev/stdout)

rm "$TEMP_FILE"

echo "🔑 Authenticating to Vault..."
VAULT_TOKEN=$(curl -s --request POST --data "{\"role\": \"vault-tf-apply\", \"jwt\": \"$SIGNED_JWT\"}" \
  $VAULT_ADDR/v1/auth/gcp/login | jq -r .auth.client_token)

echo "✅ VAULT_TOKEN retrieved."

export VAULT_TOKEN=$VAULT_TOKEN

TMP_BUILD_DIR=/tmp/build

mkdir -p $TMP_BUILD_DIR
cd $TMP_BUILD_DIR
echo "📝 Génération du fichier backend.hcl..."
cat > /tmp/backend.hcl <<EOF
bucket       = "global-europe-west1-tf-state"
prefix       = "terraform/state/vault/prod"
EOF

echo "🚀 Initialisation Terraform..."
terraform -chdir=/workspace init \
    -backend-config=/tmp/backend.hcl \
    -lockfile=readonly
terraform -chdir=/workspace apply -auto-approve