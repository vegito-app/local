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

# 📦 Prepare user runtime (useful for xpra sockets)
export XDG_RUNTIME_DIR="/run/user/$(id -u)"
sudo mkdir -p "$XDG_RUNTIME_DIR"
sudo chmod o+rw -R "$XDG_RUNTIME_DIR"

# 🖥️ Default parameters
default_resolution="1920x1080"
default_framerate="60"
default_depth="24"
default_dpi="96"
default_display_number=":1"

resolution="${DISPLAY_RESOLUTION:-$default_resolution}"
depth="${DISPLAY_DEPTH:-$default_depth}"
dpi="${DISPLAY_DPI:-$default_dpi}"
display="${DISPLAY:-$default_display_number}"
framerate="${DISPLAY_FRAMERATE:-$default_framerate}"

# 🖥️ ModeLine personnalisé
# 🔧 Extraction robuste de la largeur et hauteur
width="${resolution%x*}"    # Supprime 'x*' à partir de la fin
height="${resolution#*x}"   # Supprime '*x' depuis le début

# Generate custom modeline
custom_modeline_params=$(cvt "$width" "$height" "$framerate" | grep -oP 'Modeline\s+"[^"]*"\s+\K.*')
echo "🔍 ModeLine params extracted: $custom_modeline_params"

custom_mode_name="$resolution"
xorg_config="/tmp/xorg-xpra.conf"

echo "🛠️ Generating Xorg configuration file: $xorg_config"

# ⚙️ Write CORRECTED Xorg configuration file
cat <<EOF | sudo tee "$xorg_config" >/dev/null
Section "Device"
    Identifier  "Nvidia Card"
    Driver      "nvidia"
    VendorName  "NVIDIA Corporation"
    Option      "UseDisplayDevice" "none"
    Option      "ConnectedMonitor" "CRT-0"
    Option      "CustomEDID" "CRT-0:/etc/X11/edid.bin"
    Option      "IgnoreEDID" "false"
    Option      "UseEDID" "false"
EndSection

Section "Monitor"
    Identifier "Monitor0"
    HorizSync   30.0 - 81.0
    VertRefresh 56.0 - 75.0
    
    
    # Standard ModeLine definitions
    ModeLine "1680x1050" 146.25 1680 1784 1960 2240 1050 1053 1059 1089 -hsync +vsync
    ModeLine "1440x900" 106.50 1440 1528 1672 1904 900 903 909 934 -hsync +vsync
    ModeLine "1280x720" 74.25 1280 1390 1430 1650 720 725 730 750 +hsync +vsync
    ModeLine "1024x768" 65.00 1024 1048 1184 1344 768 771 777 806 -hsync -vsync
    ModeLine "800x600" 40.00 800 840 968 1056 600 601 605 628 +hsync +vsync

    # 🎯 ModeLine dynamique (priorité maximale - écrase les précédentes si collision)
    # Pour ${resolution} à ${framerate}Hz
    # Custom ModeLine for requested resolution
    ModeLine "$custom_mode_name" $custom_modeline_params
EndSection

Section "Screen"
    Identifier "Screen0"
    Device     "Nvidia Card"
    Monitor    "Monitor0"
    DefaultDepth $depth
    
    SubSection "Display"
        Depth $depth
        Modes "$custom_mode_name" "1680x1050" "1440x900" "1280x720" "1024x768" "800x600"
        Virtual $width $height
    EndSubSection
EndSection

Section "ServerLayout"
    Identifier "Layout0"
    Screen     "Screen0"
EndSection
EOF

echo "🚀 Starting Xorg on display $display..."
sudo Xorg "$display" -config "$xorg_config" -screen Screen0 &
bg_pids+=("$!")

until pgrep -f "Xorg $display" > /dev/null; do 
  echo "⏳ Waiting for Xorg to start on $display...";
  sleep 1; 
done

echo "✅ Xorg started successfully on $display."

# Start openbox session
# openbox-setup.sh
openbox-session &
bg_pids+=("$!")

until pgrep -f "openbox-session" > /dev/null; do 
  echo "⏳ Waiting for Openbox session to start...";
  sleep 1; 
done

until glxinfo >/dev/null 2>&1; do
    echo "⏳ Waiting for OpenGL capabilities..."
    sleep 1
done

echo "🔍 Checking OpenGL capabilities..."
glxinfo | grep -E "renderer|OpenGL" || echo "⚠️ OpenGL info not available"

# Check available modes BEFORE trying to set resolution
echo "🔍 Available display modes:"
xrandr --query

# Add the custom mode if it doesn't exist
echo "🔧 Adding custom mode if needed..."
xrandr --newmode "$custom_mode_name" $custom_modeline_params || true
xrandr --addmode HDMI-0 "$custom_mode_name" || true
xrandr --addmode DP-0 "$custom_mode_name" || true

# Try to set the resolution using different methods
echo "🎯 Setting display resolution to $resolution with DPI $dpi"

# Method 1: Direct mode setting
xrandr --output HDMI-0 --mode "$custom_mode_name" --primary || \
xrandr --output DP-0 --mode "$custom_mode_name" --primary || \
xrandr -s "$resolution" --dpi "$dpi" || \
echo "⚠️ Could not set resolution using standard methods"

# Force framebuffer size
xrandr --fb "${width}x${height}"

echo "✅ Display configuration after change:"
xrandr --query | head -10

echo "🌀 Starting x11vnc on $display with Openbox session..."
x11vnc -display "$display" -nopw -noxdamage -shared -forever -repeat &
x11vnc_bg_pid=$!
bg_pids+=("$x11vnc_bg_pid")

until pgrep -f "x11vnc -display $display" > /dev/null; do 
  echo "⏳ Waiting for x11vnc to start on $display...";
  sleep 1; 
done
echo "✅ x11vnc running on $display → http://localhost:5900/ 🖥️"

echo "🌀 Starting Xpra on $display with Openbox session..."
xpra start-desktop "$display" \
  --use-display  \
  --bind-tcp=0.0.0.0:5901   \
  --dbus-control=no \
  --dbus-launch='' \
  --dbus-proxy=no \
  --desktop-scaling=auto \
  --dpi="$dpi"   \
  --env=DISPLAY="$display" \
  --html=on \
  --min-size="$resolution" \
  --no-daemon   \
  --no-mdns   \
  --notifications=no \
  --resize-display=yes \
  --webcam=no &

xpra_pid=$!

until pgrep -f "xpra start-desktop $display" > /dev/null; do 
  echo "⏳ Waiting for Xpra to start on $display...";
  sleep 1; 
done
echo "🌀 Xpra started successfully on $display with Openbox session."

wait "$x11vnc_bg_pid" "$xpra_pid" || true
echo "🛑 Session ended."