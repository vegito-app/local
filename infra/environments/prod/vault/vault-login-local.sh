#!/bin/bash

set -exuo pipefail

# CONFIGURATION — adapte à ton projet
PROD_VAULT_ADDR="${PROD_VAULT_ADDR:-http://localhost:8210}"
ROLE="vault-admin"
SA_EMAIL="${PROJECT_USER}-prod@moov-438615.iam.gserviceaccount.com"
EXPIRATION_SECONDS=300  # doit être < 900
JWT_FILE="/tmp/vault_jwt_signed.assertion"

echo "🛠️  Génération JWT signé pour $SA_EMAIL (aud=$PROD_VAULT_ADDR/vault/$ROLE, exp=${EXPIRATION_SECONDS}s)..."

# Calcul des timestamps
NOW=$(date +%s)
EXP=$(($NOW + $EXPIRATION_SECONDS))

# Générer le JWT signé via IAM
JWT_PAYLOAD="/tmp/vault_jwt_payload.json"
JWT_SIGNED="/tmp/vault_jwt_signed.jwt"

cat <<EOF > "$JWT_PAYLOAD"
{
  "aud": "$PROD_VAULT_ADDR/vault/$ROLE",
  "exp": $EXP,
  "iat": $NOW,
  "sub": "$SA_EMAIL",
  "iss": "$SA_EMAIL"
}
EOF

gcloud iam service-accounts sign-jwt "$JWT_PAYLOAD" "$JWT_SIGNED" \
  --iam-account="$SA_EMAIL"

# Authentification Vault avec le JWT
echo "🔐 Authentification auprès de Vault..."
VAULT_TOKEN=$(curl -s --request POST \
  --data "{\"role\": \"$ROLE\", \"jwt\": \"$(cat $JWT_SIGNED)\"}" \
  "$PROD_VAULT_ADDR/v1/auth/gcp/login" | jq -r '.auth.client_token')

# Vérification
if [[ -z "$VAULT_TOKEN" || "$VAULT_TOKEN" == "null" ]]; then
  echo "❌ Échec de l'authentification Vault"
  exit 1
fi

echo "✅ Authentification réussie !"
echo "🔑 VAULT_TOKEN = $VAULT_TOKEN"

# Export pour la session
export VAULT_TOKEN

# Optionnel : tester l'accès
echo "🔍 Test de lookup :"
curl -s -H "X-Vault-Token: $VAULT_TOKEN" "$PROD_VAULT_ADDR/v1/auth/token/lookup-self" | jq

# Facultatif : stocker dans un fichier
echo "$VAULT_TOKEN" > .vault_${INFRA_ENV}_token

echo "✅ VAULT_TOKEN retrieved."
echo "💡 You can now export it with:"
echo "export VAULT_TOKEN=$VAULT_TOKEN"
