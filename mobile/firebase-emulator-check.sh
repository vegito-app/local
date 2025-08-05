#!/bin/bash
set -e

APP_ID="dev.vegito.app.android"  # <- à adapter si flavors
APK_PATH="build/app/outputs/flutter-apk/app-debug.apk"

echo "🔍 Vérification de l'APK ($APK_PATH)..."
if [ ! -f "$APK_PATH" ]; then
  echo "❌ APK non trouvé. Lance d'abord : flutter build apk"
  exit 1
fi

echo "📦 Extraction du SHA-1 de l'APK signé..."
AAPT=$(find $ANDROID_SDK_ROOT/build-tools -name aapt | sort -V | tail -1)
if [ -z "$AAPT" ]; then
  echo "❌ aapt non trouvé. Assure-toi que build-tools est bien installé."
  exit 1
fi

SHA1=$(keytool -printcert -jarfile "$APK_PATH" | grep SHA1 | awk '{print $2}')
echo "✅ SHA-1 de l'APK : $SHA1"

echo "🔑 SHA-1 à ajouter (si ce n'est pas déjà fait) dans Firebase Console > Projet > Android > $APP_ID"
echo "    🔗 https://console.firebase.google.com/project/_/settings/general"

echo ""
echo "📡 Test de réseau vers Firebase Installations et Messaging..."

echo "🛰️  Vérification DNS et connectivité Firebase:"
nslookup firebaseinstallations.googleapis.com || echo "⚠️ Problème DNS ?"
curl -s --head https://firebaseinstallations.googleapis.com | grep "HTTP/" || echo "⚠️ Injoignable !"

echo ""
echo "📲 Connexion ADB avec l'émulateur..."
DEVICE_ID=$(adb devices | grep emulator | awk '{print $1}')
if [ -z "$DEVICE_ID" ]; then
  echo "❌ Aucun émulateur connecté. Démarre-en un avec Android Studio ou emulator CLI."
  exit 1
fi
echo "✅ Émulateur détecté : $DEVICE_ID"

echo ""
echo "📜 Vérification du Manifest (package name + MainActivity)..."
aapt dump xmltree "$APK_PATH" AndroidManifest.xml | grep -E 'A: android:name|A: package'
echo "✅ Si le nom de package = $APP_ID, c’est bon."

echo ""
echo "🧪 Logcat (dernier FCM/messaging log)..."
adb -s "$DEVICE_ID" logcat -d | grep -i -E "FirebaseMessaging|FIS|firebase install|AUTHENTICATION_FAILED" | tail -n 30

echo ""
echo "🎯 Terminé. Si FCM échoue encore, vérifie :"
echo "- Le fichier google-services.json correspond bien au bon flavor + nom d'application"
echo "- Tu as autorisé le SHA-1 dans Firebase Console"
echo "- L'émulateur a bien Internet (curl test)"