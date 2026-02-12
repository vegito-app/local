#!/bin/bash

set -euo pipefail

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

if [ ${LOCAL_ANDROID_CONTAINER_DISPLAY_START:-"true"} = "true" ]; then
case "${LOCAL_ANDROID_GPU_MODE:-swiftshader_indirect}" in
    "host")
        display-start-xorg-host.sh &
        bg_pids+=("$!")
        ;;
    "swiftshader_indirect" | "guest" | *)
        display-start.sh &
        bg_pids+=("$!")
        ;;
esac
fi

# Forward firebase-emulators to container as localhost
socat TCP-LISTEN:9299,fork,reuseaddr TCP:firebase-emulators:9399 > /tmp/socat-firebase-emulators-9399.log 2>&1 &
bg_pids+=("$!")
socat TCP-LISTEN:4500,fork,reuseaddr TCP:firebase-emulators:4501 > /tmp/socat-firebase-emulators-4501.log 2>&1 &
bg_pids+=("$!")
socat TCP-LISTEN:4400,fork,reuseaddr TCP:firebase-emulators:4401 > /tmp/socat-firebase-emulators-4401.log 2>&1 &
bg_pids+=("$!")
socat TCP-LISTEN:9000,fork,reuseaddr TCP:firebase-emulators:9000 > /tmp/socat-firebase-emulators-9000.log 2>&1 &
bg_pids+=("$!")
socat TCP-LISTEN:9099,fork,reuseaddr TCP:firebase-emulators:9099 > /tmp/socat-firebase-emulators-9099.log 2>&1 &
bg_pids+=("$!")
socat TCP-LISTEN:9150,fork,reuseaddr TCP:firebase-emulators:9150 > /tmp/socat-firebase-emulators-9150.log 2>&1 &
bg_pids+=("$!")
socat TCP-LISTEN:9199,fork,reuseaddr TCP:firebase-emulators:9199 > /tmp/socat-firebase-emulators-9199.log 2>&1 &
bg_pids+=("$!")
socat TCP-LISTEN:8085,fork,reuseaddr TCP:firebase-emulators:8085 > /tmp/socat-firebase-emulators-8085.log 2>&1 &
bg_pids+=("$!")
socat TCP-LISTEN:8090,fork,reuseaddr TCP:firebase-emulators:8090 > /tmp/socat-firebase-emulators-8090.log 2>&1 &
bg_pids+=("$!")
socat TCP-LISTEN:5001,fork,reuseaddr TCP:firebase-emulators:5001 > /tmp/socat-firebase-emulators-5001.log 2>&1 &
bg_pids+=("$!")
socat TCP-LISTEN:4000,fork,reuseaddr TCP:firebase-emulators:4000 > /tmp/socat-firebase-emulators-4000.log 2>&1 &
bg_pids+=("$!")

# access to backend using localhost (position retrieval unauthorized using insecure http frontend with google-chrome)
socat TCP-LISTEN:8080,fork,reuseaddr TCP:application-backend:8080 > /tmp/socat-backend-8080.log 2>&1 &
bg_pids+=("$!")

# access to debug backend using localhost (position retrieval unauthorized using insecure http frontend with google-chrome)
socat TCP-LISTEN:8888,fork,reuseaddr TCP:devcontainer:8888 > /tmp/socat-devcontainer-8888.log 2>&1 &
bg_pids+=("$!")

if [ -e /dev/kvm ]; then
  KVM_GID_EXPECTED=$(stat -c '%g' /dev/kvm)
  if ! id -G | tr ' ' '\n' | grep -qx "$KVM_GID_EXPECTED"; then
    echo "❌ ERROR: android user is not in /dev/kvm group ($KVM_GID_EXPECTED)"
    exit 1
  fi
fi

if [ "${LOCAL_ANDROID_EMULATOR_AVD_ON_START}" = "true" ]; then
    android-emulator-avd-start.sh &
    # Don't track this PID as the script will exit after starting the emulator if it is restarted (using 'make local-android-emulator-avd-restart' for example)
    # bg_pids+=($!) 
    # ⏳ Attente du boot complet de l'émulateur
    echo "⏳ Waiting for full Android boot..."

    if [ "${LOCAL_ANDROID_EMULATOR_AVD_ON_START}" = "false" ]; then
        echo "ℹ️ Skipping AVD start as LOCAL_ANDROID_EMULATOR_AVD_ON_START is set to false."
        exit 0
    fi

    adb wait-for-device

    until adb shell getprop sys.boot_completed | grep -q "1"; do
    echo "⏳ Android not booted yet..."
    sleep 2
    done

    while [[ "$(adb shell getprop init.svc.bootanim 2>/dev/null)" != *"stopped"* ]]; do
    echo "🎞️ Boot animation still running..."
    sleep 2
    done

    # Optionnel : check de réactivité ADB shell
    until adb shell "echo ok" | grep -q "ok"; do
    echo "🔁 Waiting for ADB shell..."
    sleep 2
    done
fi

# Developer-friendly aliases
alias gs='git status'
alias gb='git branch'
alias gd='git diff'
alias gl='git log --oneline --graph --decorate'
alias flutter-clean='flutter clean && rm -rf .dart_tool .packages pubspec.lock build'
alias run-android='flutter run -d android'

# echo fs.inotify.max_user_watches=524288 |  sudo tee -a /etc/sysctl.conf; sudo sysctl -p

if [ $# -eq 0 ]; then
  echo "[entrypoint] No command passed, waiting.   to keep container alive"
  wait "${bg_pids[@]}"
else
  exec "$@"
fi
