#!/bin/bash
set -euo pipefail

IMAGE_DIR="${1:-${IMAGE_DIR:-./images}}"

# Vérifie si un appareil est connecté
if ! adb devices | grep -w "device" >/dev/null; then
  echo "❌ Aucun appareil détecté via adb. L'émulateur est-il lancé ?"
  exit 1
fi

echo "📁 Chargement des images depuis : $IMAGE_DIR"
if [ ! -d "$IMAGE_DIR" ]; then
  echo "❌ Le répertoire $IMAGE_DIR n'existe pas."
  exit 1
fi
# Wait until the system property sys.boot_completed is 1
echo "⏳ Waiting for Android system to complete boot..."
until adb shell getprop sys.boot_completed | grep -m 1 "1"; do
  sleep 1
done
echo "✅ Android system boot complete."

# Now /sdcard should be mounted — check again
until adb shell ls /sdcard >/dev/null 2>&1; do
  echo "⏳ Waiting for /sdcard to be accessible..."
  sleep 1
done

# Wait until /sdcard is writable
echo "⏳ Waiting for /sdcard to be writable..."
until adb shell 'touch /sdcard/.testfile' >/dev/null 2>&1; do
  sleep 1
done
adb shell rm /sdcard/.testfile
echo "✅ /sdcard is writable."

echo "📦 Creating destination folder on device..."
adb shell mkdir -p /sdcard/TestImagesDepot
adb shell touch /sdcard/TestImagesDepot/.nomedia

# Push all images from the specified directory to the device
for img in "$IMAGE_DIR"/*.{jpg,jpeg,png}; do
  [ -e "$img" ] || continue
  filename=$(basename "$img")
  echo "📤 Pushing $filename ..."
  adb push "$img" "/sdcard/TestImagesDepot/$filename"
done

echo "✅ All images have been copied to /sdcard/TestImagesDepot/"