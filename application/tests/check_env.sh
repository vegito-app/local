

#!/bin/bash

set -eu

echo "🔍 Vérification de l'environnement de test..."

check_command() {
    if ! command -v "$1" >/dev/null 2>&1; then
        echo "❌ Commande introuvable : $1"
        exit 1
    else
        echo "✅ $1 est disponible"
    fi
}

check_url() {
    local name="$1"
    local url="$2"
    if curl -s --fail --max-time 2 "$url" >/dev/null; then
        echo "✅ $name est accessible à $url"
    else
        echo "❌ $name n'est pas accessible à $url"
        exit 1
    fi
}

# Vérifie les outils CLI nécessaires
check_command curl
check_command adb
check_command python3
check_command robot

# Vérifie les endpoints essentiels
check_url "Backend" "${APPLICATION_BACKEND_URL}"
check_url "Firebase Auth Emulator" "http://${FIREBASE_AUTH_EMULATOR_HOST}"
check_url "Firestore Emulator" "http://${FIRESTORE_EMULATOR_HOST}"
echo "🔍 Vérification du serveur Appium (port 4723)..."
if curl -s --fail --max-time 2 http://${ANDROID_HOST}:4723/wd/hub/status | jq -e '.value.ready == true' >/dev/null; then
    echo "✅ Appium est prêt sur ${ANDROID_HOST}:4723"
else
    echo "❌ Appium n'est pas prêt ou ne répond pas correctement sur ${ANDROID_HOST}:4723"
    exit 1
fi
echo "✅ Tous les prérequis sont satisfaits."