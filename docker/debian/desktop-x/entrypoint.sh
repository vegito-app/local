#!/bin/bash

set -euo pipefail

export XPRA_SOCKET_DIR="$XDG_RUNTIME_DIR/xpra"
export XPRA_SOCKET_DIRS="$XPRA_SOCKET_DIR"
mkdir -p "$XPRA_SOCKET_DIR"

# start a dbus session (required by pulseaudio/xpra)
eval "$(dbus-launch --sh-syntax)"
export DBUS_SESSION_BUS_ADDRESS
export DBUS_SESSION_BUS_PID

desktop-x-install.sh

exec "$@"