#!/bin/bash

set -eu

echo "Démarrage du serveur adb si absent..."
if ! pgrep -x "adb" >/dev/null; then
  adb start-server
fi

echo "Lancement de l’AVD nommé : ${ANDROID_AVD_NAME:-Pixel_8_Intel}"
emulator -avd "${ANDROID_AVD_NAME:-Pixel_8_Intel}" \
  -gpu swiftshader_indirect \
  -noaudio -no-snapshot-load \
  -no-boot-anim \
  -qemu &

until adb devices | grep -w "device$"; do
  echo "En attente qu'un appareil ADB soit connecté..."
  sleep 2
done

echo "Lancement du serveur Appium..."
appium --address 0.0.0.0 --port 4723 \
  --session-override --log-level info \
  --allow-insecure=adb_shell &

load_tests_data.sh ${IMAGE_DIR:-./images}