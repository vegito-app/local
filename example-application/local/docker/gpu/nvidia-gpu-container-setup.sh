#!/usr/bin/env bash

# Script to install and validate GPU support with Docker on Debian-based systems

set -euo pipefail

echo "=== [1/7] Checking for NVIDIA GPU..."
nvidia-smi

echo "=== [2/7] Checking for NVIDIA devices..."
ls /dev/nvidia* 

echo "=== [3/7] Detecting distribution..."
distribution=$(. /etc/os-release; echo $ID$VERSION_ID)
echo "Detected: $distribution"

echo "=== [4/7] Adding NVIDIA Docker repository..."

sudo mkdir -p /etc/apt/keyrings

curl -fsSL https://nvidia.github.io/nvidia-docker/gpgkey | \
  sudo gpg --dearmor -o /etc/apt/keyrings/nvidia-container-toolkit-keyring.gpg

curl -s -L https://nvidia.github.io/nvidia-docker/$distribution/nvidia-docker.list | \
  sed 's#^deb #deb [signed-by=/etc/apt/keyrings/nvidia-container-toolkit-keyring.gpg] #' | \
  sudo tee /etc/apt/sources.list.d/nvidia-docker.list > /dev/null

echo "=== [5/7] Installing NVIDIA container toolkit..."

sudo apt-get update
sudo apt-get install -y nvidia-container-toolkit

echo "=== [6/7] Configuring Docker daemon..."

sudo nvidia-ctk runtime configure --runtime=docker
sudo systemctl restart docker || echo "⚠️ Docker service restart failed. Restart it manually if needed."

echo "=== [7/7] Testing with CUDA container..."

docker run --rm --gpus all nvidia/cuda:12.2.0-base-ubuntu20.04 nvidia-smi

echo "✅ NVIDIA Docker GPU setup complete."
