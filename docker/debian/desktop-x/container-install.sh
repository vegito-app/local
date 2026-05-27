#!/bin/bash
set -euo pipefail


container_desktop_x_debian_install_success=false
# 🧹 Function called at the end of the script to check for success
check_success() {
    if [ $container_desktop_x_debian_install_success = true ]; then
        echo "♻️ Desktop-X Debian container installed successfully."
    else
        echo "❌ Desktop-X Debian container installation failed."
    fi
}

# 🚨 Register cleanup function to run on script exit
trap check_success EXIT

mkdir -p ~/.bashrc.d

cat <<EOF > ~/.bashrc.d/30-desktop-x.sh
# Environment Variables

export DISPLAY=:99
export XDG_RUNTIME_DIR=/run/user/$(id -u)
export WAYLAND_DISPLAY=wayland-0
export XPRA_SOCKET_DIR="${XPRA_SOCKET_DIR:-${XDG_RUNTIME_DIR}/xpra}"
export XPRA_SOCKET_DIRS="${XPRA_SOCKET_DIRS:-${XDG_RUNTIME_DIR}/xpra}"
export XAUTHORITY=${XAUTHORITY:-${HOME}/.Xauthority}
export XDG_SESSION_TYPE=${XDG_SESSION_TYPE:-x11}
export QT_X11_NO_MITSHM=1
export LIBGL_ALWAYS_INDIRECT=0
export LIBVA_DRIVER_NAME=nvidia
export __GLX_VENDOR_LIBRARY_NAME=nvidia
export __NV_PRIME_RENDER_OFFLOAD=1
export NVIDIA_DRIVER_CAPABILITIES=all
export NVIDIA_VISIBLE_DEVICES=all
export CUDA_HOME=/usr/local/cuda
export NVIDIA_REQUIRE_CUDA="cuda>=12.2"

# Developer friendly aliases

alias xpra-list='xpra list'
alias xpra-stop='xpra stop :99'
alias xlog='tail -f /tmp/Xorg.99.log'
alias westlog='tail -f /tmp/weston.log'
alias nsmi='watch -n1 nvidia-smi'

alias ngpu='nvidia-smi'

alias ngpup='nvidia-smi pmon'
alias ngl='glxinfo | grep OpenGL'
alias ncuda='nvcc --version'
EOF

container_desktop_x_debian_install_success=true