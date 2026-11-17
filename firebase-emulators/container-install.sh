#!/bin/bash
set -euo pipefail


container_firebase_emulators_install_success=false
# 🧹 Function called at the end of the script to check for success
check_success() {
    if [ $container_firebase_emulators_install_success = true ]; then
        echo "♻️ Debian container installed successfully."
    else
        echo "❌ Debian container installation failed."
    fi
}

# 🚨 Register cleanup function to run on script exit
trap check_success EXIT

# Bashrc enhancements for better usability
mkdir -p ~/.bashrc.d

if ! grep -q "__BASHRC_D" ~/.bashrc; then

cat <<'EOF' >> ~/.bashrc
# __BASHRC_D
if [ -d "${HOME}/.bashrc.d" ]; then
    for f in "${HOME}"/.bashrc.d/*.sh; do
        [ -r "$f" ] && source "$f"
    done
fi

EOF
fi

cat <<'EOF' > ~/.bashrc.d/100-firebase-emulators.sh

# Firebase Emulator UI utilise certains services auxiliaires uniquement
# exposés sur localhost. On les réexpose sur le réseau Docker avec un
# port différent afin qu'un autre container puisse les ramener sur son
# propre localhost.
forward_loopback_port() {
    local source_port="$1"
    local bridge_port="$2"
    local timeout_seconds="${3:-60}"
    local elapsed=0

    echo "[firebase-emulators] Waiting for 127.0.0.1:${source_port}..."

    while ! nc -z 127.0.0.1 "${source_port}" 2>/dev/null; do
        if (( elapsed >= timeout_seconds )); then
            echo "[firebase-emulators] WARNING: 127.0.0.1:${source_port} unavailable after ${timeout_seconds}s; skipping bridge ${bridge_port}"
            return 0
        fi

        sleep 1
        ((elapsed += 1))
    done

    echo "[firebase-emulators] Port 127.0.0.1:${source_port} is ready"
    echo "[firebase-emulators] Forwarding 0.0.0.0:${bridge_port} -> 127.0.0.1:${source_port}"

    socat \
        "TCP-LISTEN:${bridge_port},bind=0.0.0.0,fork,reuseaddr" \
        "TCP:127.0.0.1:${source_port}"
}

EOF

local_container_cache=${LOCAL_FIREBASE_EMULATORS_CACHE:-${LOCAL_DIR:-${PWD}}/.firebase-emulators}
mkdir -p $local_container_cache

# Firebase Emulators config
FIREBASE_EMULATORS_CACHE=${HOME}/.cache
mkdir -p $local_container_cache/.cache
ln -s $local_container_cache/.cache $FIREBASE_EMULATORS_CACHE


container_firebase_emulators_install_success=true
