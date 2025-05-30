#!/bin/bash
set -euo pipefail

IMAGE_DIR="${1:-./images}"

# Vérifie si un appareil est connecté
if ! adb devices | grep -w "device" >/dev/null; then
  echo "❌ Aucun appareil détecté via adb. L'émulateur est-il lancé ?"
  exit 1
fi

echo "📁 Chargement des images depuis : $IMAGE_DIR"

for img in "$IMAGE_DIR"/*.{jpg,jpeg,png}; do
  [ -e "$img" ] || continue
  filename=$(basename "$img")
  echo "📤 Pushing $filename ..."
  adb push "$img" "/sdcard/Pictures/$filename"
  adb shell am broadcast -a android.intent.action.MEDIA_SCANNER_SCAN_FILE -d "file:///sdcard/Pictures/$filename" >/dev/null
done

echo "✅ Toutes les images ont été copiées dans /sdcard/Pictures/"