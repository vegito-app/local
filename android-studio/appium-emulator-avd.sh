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

echo "Liste des AVD disponibles :"
emulator -list-avds

avd_to_use="${ANDROID_AVD_NAME:-Pixel_8_Pro}"
echo "AVD à utiliser : ${avd_to_use}"

# 🧹 Nettoyage de l'AVD existant si nécessaire
if emulator -list-avds | grep -q "${avd_to_use}"; then
  echo "Nettoyage de l'AVD existant nommé ${avd_to_use}..."
  emulator -avd "${avd_to_use}" -no-snapshot-save -wipe-data || true
else
  echo "Aucun AVD nommé ${avd_to_use} trouvé, création d'un nouvel AVD..."
  # Création d'un nouvel AVD si il n'existe pas
  avdmanager create avd -n "${avd_to_use}" \
    -k "system-images;android-34;google_apis;x86" \
    --device "pixel_8" --force --abi "x86" || true
fi

echo "Lancement de l’AVD nommé : ${avd_to_use}"
emulator -avd "${avd_to_use}" \
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

emulator-data-load.sh ${IMAGE_DIR:-./images}

sleep infinity