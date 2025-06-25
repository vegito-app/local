#!/bin/bash

set -eu


# 📌 List of PIDs of background processes
bg_pids=()

# 🧹 Function called at the end of the script to kill background processes
kill_jobs() {
    echo "🧼 Cleaning up background processes..."
    for pid in "${bg_pids[@]}"; do
        kill "$pid" || true
        wait "$pid" 2>/dev/null || true
    done
}

# 🚨 Register cleanup function to run on script exit
trap kill_jobs EXIT

echo "Démarrage du serveur adb si absent..."
if ! pgrep -x "adb" >/dev/null; then
  adb start-server
fi

echo "Lancement de l’AVD nommé : ${ANDROID_AVD_NAME:-Pixel_8_Intel}"
emulator -avd "${ANDROID_AVD_NAME:-Pixel_8_Intel}" \
  -gpu ${ANDROID_GPU_MODE:-swiftshader_indirect} \
  -noaudio -no-snapshot-load \
  -no-boot-anim \
  -qemu &
bg_pids+=($!)

until adb devices | grep -w "device$"; do
  echo "En attente qu'un appareil ADB soit connecté..."
  sleep 2
done

echo "Lancement du serveur Appium..."
appium --address 0.0.0.0 --port 4723 \
  --session-override --log-level info \
  --allow-insecure=adb_shell &
bg_pids+=($!)
echo "Appium est prêt à accepter les connexions sur le port 4723."

load_tests_data.sh ${IMAGE_DIR:-./images}

sleep infinity