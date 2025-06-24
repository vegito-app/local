#!/bin/bash

set -eux

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

# 📦 Prepare user runtime (useful for xpra sockets)
export XDG_RUNTIME_DIR="/run/user/$(id -u)"
sudo mkdir -p "$XDG_RUNTIME_DIR"
sudo chmod o+rw -R "$XDG_RUNTIME_DIR"

# 🖥️ Default parameters
default_resolution="1920x1080"
default_depth="24"
default_dpi="96"
default_display_number=":1"

resolution="${DISPLAY_RESOLUTION:-$default_resolution}"
depth="${DISPLAY_DEPTH:-$default_depth}"
dpi="${DISPLAY_DPI:-$default_dpi}"
display="${DISPLAY_NUMBER:-$default_display_number}"

xorg_config="/tmp/xorg-xpra.conf"

echo "🛠️ Generating Xorg configuration file: $xorg_config"

# ⚙️ Write Xorg configuration file
cat <<EOF | sudo tee "$xorg_config" >/dev/null
Section "Device"
    Identifier  "Nvidia Card"
    Driver      "nvidia"
    VendorName  "NVIDIA Corporation"
    Option      "AllowEmptyInitialConfiguration" "true"
EndSection

Section "Monitor"
    Identifier "Monitor0"
EndSection

Section "Screen"
    Identifier "Screen0"
    Device     "Nvidia Card"
    Monitor    "Monitor0"
    DefaultDepth ${depth}
    SubSection "Display"
        Depth ${depth}
        Modes "${resolution}"
    EndSubSection
EndSection
EOF

echo "🚀 Starting Xorg on display ${display}..."
sudo Xorg "${display}" -config "$xorg_config" &
bg_pids+=("$!")

echo "🌀 Starting Xpra with Openbox..."
xpra start "${display}" \
  --start-child=openbox-session \
  --bind-tcp=0.0.0.0:5900 \
  --html=on \
  --dpi="${dpi}" \
  --exit-with-children=yes \
  --daemon=yes \
  --env=DISPLAY="${display}"

echo "✅ Xpra running on ${display} → http://localhost:5900/ 🖥️"
sleep infinity