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

export XPRA_SOCKET_DIR="$XDG_RUNTIME_DIR/xpra"
export XPRA_SOCKET_DIRS="$XPRA_SOCKET_DIR"
mkdir -p "$XPRA_SOCKET_DIR"

# start a dbus session (required by pulseaudio/xpra)
eval "$(dbus-launch --sh-syntax)"
export DBUS_SESSION_BUS_ADDRESS
export DBUS_SESSION_BUS_PID

# 🔊 Start a persistent PulseAudio daemon for the whole container session
pulseaudio \
    --daemonize=yes \
    --system=false \
    --disallow-exit \
    --exit-idle-time=-1 \
    --log-target=stderr

for i in $(seq 1 10); do
    if pactl info >/dev/null 2>&1; then
        echo "🔊 PulseAudio ready"
        break
    fi
    echo "⏳ Waiting for PulseAudio..."
    sleep 1
done

# 🔍 Debug PulseAudio availability
pactl info

if [ ${LOCAL_DESKTOP_X_CONTAINER_DISPLAY_START:-"true"} = "true" ]; then
case "${LOCAL_DESKTOP_X_GPU_MODE:-swiftshader_indirect}" in
    "host")
        display-start-xorg-host.sh &
        bg_pids+=("$!")
        ;;
    "wayland")
        display-start-wayland.sh &
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

# Developer-friendly aliases
alias gs='git status'
alias gb='git branch'
alias gd='git diff'
alias gl='git log --oneline --graph --decorate'

# echo fs.inotify.max_user_watches=524288 |  sudo tee -a /etc/sysctl.conf; sudo sysctl -p

if [ $# -eq 0 ]; then
  echo "[entrypoint] No command passed, waiting.   to keep container alive"
  wait "${bg_pids[@]}"
else
  exec "$@"
fi
