#!/usr/bin/env bash

# Script to install and validate GPU support with Docker on Debian-based systems

set -euo pipefail


echo "=== [0/4] Checking for NVIDIA GPU..."
if ! lspci | grep -i nvidia > /dev/null; then
  echo "❌ No NVIDIA GPU detected. Please ensure one is installed."
  exit 1
fi

echo "=== [1/4] Verifying Debian Bookworm system..."
source /etc/os-release
if [[ \"$ID\" != \"debian\" || \"$VERSION_CODENAME\" != \"bookworm\" ]]; then
  echo \"❌ This script is intended for Debian Bookworm. Detected: $PRETTY_NAME\"
  exit 1
fi

echo "=== [2/4] Adding non-free repositories..."
sudo tee /etc/apt/sources.list.d/debian-bookworm.list > /dev/null <<EOF
deb http://deb.debian.org/debian bookworm main contrib non-free non-free-firmware
EOF

echo "=== [3/4] Installing NVIDIA driver..."
sudo apt update
sudo apt install -y nvidia-driver firmware-misc-nonfree

echo "=== [4/4] Installation complete."
echo "🔁 Please reboot your system to activate the NVIDIA driver."