#!/usr/bin/env bash

set -euo pipefail

log() {
  echo -e "\n=== $1 ==="
}

fail() {
  echo "❌ $1"
  exit 1
}

# --- [0] Check GPU ---
log "[0/6] Checking NVIDIA GPU"
if ! lspci | grep -i nvidia > /dev/null; then
  fail "No NVIDIA GPU detected"
fi

# --- [1] Check Debian ---
log "[1/6] Checking OS"
source /etc/os-release
if [[ "$ID" != "debian" || "$VERSION_CODENAME" != "bookworm" ]]; then
  fail "Expected Debian Bookworm, got: $PRETTY_NAME"
fi

# --- [2] Detect RT kernel ---
log "[2/6] Checking kernel"
KERNEL=$(uname -r)
if [[ "$KERNEL" == *"rt"* ]]; then
  echo "⚠️ RT kernel detected ($KERNEL)"
  echo "⚠️ NVIDIA driver may FAIL to build with DKMS"
  echo "👉 Recommended: switch to standard kernel (linux-image-amd64)"
fi

# --- [3] Clean APT sources (avoid duplicates) ---
log "[3/6] Fixing APT sources"

# ensure non-free repos are present without overriding user config
if ! grep -q "non-free" /etc/apt/sources.list; then
  echo "⚠️ non-free repos missing, adding them"

  sudo tee /etc/apt/sources.list.d/non-free.list > /dev/null <<EOF
deb http://deb.debian.org/debian bookworm main contrib non-free non-free-firmware
deb http://deb.debian.org/debian-security bookworm-security main contrib non-free non-free-firmware
deb http://deb.debian.org/debian bookworm-updates main contrib non-free non-free-firmware
EOF
fi

sudo apt clean
sudo rm -rf /var/lib/apt/lists/*
sudo apt update

# --- [4] Install kernel headers ---
log "[4/6] Installing kernel headers"
sudo apt install -y build-essential dkms linux-headers-amd64 || \
sudo apt install -y linux-headers-$(uname -r)

# --- [5] Install NVIDIA driver ---
log "[5/6] Installing NVIDIA driver"

sudo apt install -y nvidia-driver firmware-misc-nonfree || {
  echo "⚠️ Driver install failed. Likely due to RT kernel."
}

# --- [6] Docker NVIDIA runtime ---
log "[6/6] Installing NVIDIA container toolkit"

distribution=$(. /etc/os-release;echo $ID$VERSION_ID)

curl -fsSL https://nvidia.github.io/libnvidia-container/gpgkey | \
  sudo gpg --dearmor -o /usr/share/keyrings/nvidia-container-toolkit-keyring.gpg

curl -fsSL https://nvidia.github.io/libnvidia-container/$distribution/libnvidia-container.list | \
  sed 's#deb https://#deb [signed-by=/usr/share/keyrings/nvidia-container-toolkit-keyring.gpg] https://#g' | \
  sudo tee /etc/apt/sources.list.d/nvidia-container-toolkit.list

sudo apt update
sudo apt install -y nvidia-container-toolkit

sudo nvidia-ctk runtime configure --runtime=docker
sudo systemctl restart docker || true

# --- Final ---
log "DONE"

echo "👉 Reboot required"
echo "👉 After reboot: nvidia-smi"
echo "👉 Docker test: docker run --rm --gpus all nvidia/cuda:12.3.0-base nvidia-smi"