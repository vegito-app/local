#!/bin/bash

set -euxo pipefail

# Nettoyage du flag d'état à chaque arrêt
rm -f /tmp/.xdisplay-ready
# 📌 List of PIDs of background processes
bg_pids=()

# 🧹 Function called at the end of the script to kill background processes
kill_jobs() {
    rm -f /tmp/.xdisplay-ready
    echo "🧼 Cleaning up background processes..."
    for pid in "${bg_pids[@]}"; do
        kill "$pid" || true
        wait "$pid" 2>/dev/null || true
    done
}

# 🚨 Register cleanup function to run on script exit
trap kill_jobs EXIT

# 📦 Prepare user runtime (useful for xpra sockets)
export XDG_RUNTIME_DIR="/tmp/runtime-$(id -u)"
mkdir -p "$XDG_RUNTIME_DIR"
chmod 700 "$XDG_RUNTIME_DIR"

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
# xrandr --addmode HDMI-0 "$custom_mode_name" || true
# xrandr --addmode DP-0 "$custom_mode_name" || true

# Try to set the resolution using different methods
echo "🎯 Setting display resolution to $resolution with DPI $dpi"

# Method 1: Direct mode setting
# xrandr --output HDMI-0 --mode "$custom_mode_name" --primary || \
# xrandr --output DP-0 --mode "$custom_mode_name" --primary || \
xrandr -s "$resolution" --dpi "$dpi" || \
echo "⚠️ Could not set resolution using standard methods"

# Force framebuffer size
xrandr --fb "${width}x${height}"

echo "✅ Display configuration after change:"
xrandr --query | head -10

ENABLE_AUDIO="${ENABLE_AUDIO:-0}"
if [ "$ENABLE_AUDIO" = "1" ]; then
    echo "🔊 Audio enabled (xpra managed)"
    XPRA_AUDIO_FLAGS="--pulseaudio=yes --speaker=on --microphone=off"
else
    echo "🔇 Audio disabled"
    XPRA_AUDIO_FLAGS="--pulseaudio=no --speaker=off --microphone=off"
fi

export XPRA_SOCKET_DIR="$XDG_RUNTIME_DIR/xpra"
mkdir -p "$XPRA_SOCKET_DIR"

DISPLAY_MODE="${DISPLAY_MODE:-xpra}"

if [ "$DISPLAY_MODE" = "xpra" ]; then

echo "🌀 Starting Xpra on $display with Openbox session..."
    xpra start-desktop "$display" \
    --use-display \
    --start-child=openbox-session \
    --exit-with-children \
    --socket-dir="$XPRA_SOCKET_DIR" \
    --socket-dirs="$XPRA_SOCKET_DIR" \
    --bind-tcp=0.0.0.0:5901 \
    ${XPRA_AUDIO_FLAGS} \
    --desktop-scaling=auto \
    --dpi="$dpi" \
    --env=DISPLAY="$display" \
    --html=on \
    --min-size="$resolution" \
    --no-daemon \
    --no-mdns \
    --notifications=no \
    --resize-display=yes \
    --webcam=no &
    display_pid=$!

    XPRA_SOCKET="$XPRA_SOCKET_DIR/$(hostname)-${display#:}"

    until [ -S "$XPRA_SOCKET" ]; do
        echo "⏳ Waiting for xpra socket..."
        sleep 1
    done
    echo "🌀 Xpra started successfully on $display with Openbox session."

elif [ "$DISPLAY_MODE" = "vnc" ]; then

    echo "🌀 Starting x11vnc..."
    echo "🌀 Starting x11vnc on $display..."
    x11vnc -display "$display" -nopw -noxdamage -shared -forever -repeat &
    display_pid=$!

    until pgrep -f "x11vnc -display $display" > /dev/null; do 
    echo "⏳ Waiting for x11vnc to start on $display...";
    sleep 1; 
    done
    echo "✅ x11vnc running on $display → http://localhost:5900/ 🖥️"
    
    openbox-session &
    bg_pids+=("$!")

else
    echo "⚠️ Invalid display mode. Please choose 'xpra' or 'vnc'."
fi


# Création d'un flag indiquant que tout le display est prêt
echo "{\"status\":\"ready\",\"ts\":$(date +%s)}" > /tmp/.xdisplay-ready

wait "$display_pid" || true
echo "🛑 Session ended."