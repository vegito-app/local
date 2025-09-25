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

emulator-entrypoint.sh &
bg_pids+=("$!")

# echo fs.inotify.max_user_watches=524288 |  sudo tee -a /etc/sysctl.conf; sudo sysctl -p

if [ "${LOCAL_ANDROID_STUDIO_APPIUM_EMULATOR_AVD_ON_START}" = "true" ]; then
    appium-emulator-avd.sh &
    bg_pids+=("$!")
fi

if [ $# -eq 0 ]; then
  echo "[entrypoint] No command passed, entering sleep infinity to keep container alive"
  wait "${bg_pids[@]}" &
  sleep infinity
else
  exec "$@"
fi
