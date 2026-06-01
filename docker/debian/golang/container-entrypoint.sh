#!/bin/bash

set -euo pipefail

# 🐧 Setup Debian
debian-entrypoint.sh echo "✅ Debian setup complete."

# Local container installation script to setup persistent configurations and caches.
# If VEGITO_GOLANG_DEBIAN_CONTAINER_INSTALL is set to "true", run the debian-golang-container-install.sh script
# to install the necessary configurations and caches.
# This is useful for local development environments where you want to keep your settings across container rebuilds.
# You can set this variable in your devcontainer.json or in your environment before starting the container.
# Example: export VEGITO_GOLANG_DEBIAN_CONTAINER_INSTALL=true
if [ "${VEGITO_GOLANG_DEBIAN_CONTAINER_INSTALL:-}" = true ]; then
    debian-golang-container-install.sh
fi

# Run the command
exec "$@"