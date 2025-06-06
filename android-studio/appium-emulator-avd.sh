#!/bin/bash

set -eu

echo "Démarrage du serveur adb si absent..."
if ! pgrep -x "adb" >/dev/null; then
  adb start-server
fi

# Lancement de l’émulateur selon architecture
if [ "$(uname -m)" = "x86_64" ]; then
  echo "Lancement AVD Intel"
  emulator -avd Pixel_8_Intel \
    -gpu swiftshader_indirect \
    -noaudio -no-snapshot-load \
    -no-boot-anim \
    -qemu &
  # emulator -avd Pixel_8_Intel -no-snapshot-load -no-window -gpu swiftshader_indirect -noaudio -no-boot-anim -emulator-window-metrics auto &
else
  echo "Lancement AVD ARM64"
  emulator -avd Pixel_8_ARM64 \
    -gpu swiftshader_indirect \
    -noaudio -no-snapshot-load \
    -no-boot-anim \
    -qemu &
  # emulator -avd Pixel_8_ARM64 -no-snapshot-load -no-window -gpu swiftshader_indirect -noaudio -no-boot-anim -emulator-window-metrics auto &
fi

until adb devices | grep -w "device$"; do
  echo "En attente qu'un appareil ADB soit connecté..."
  sleep 2
done

echo "Lancement du serveur Appium..."
appium --address 0.0.0.0 --port 4723 \
  --session-override --log-level info \
  --allow-insecure=adb_shell &

load_tests_data.sh ${IMAGE_DIR:-./images}