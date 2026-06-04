#!/bin/bash

set -euo pipefail

# Local container installation script to setup persistent configurations and caches.
# If LOCAL_CONTAINER_INSTALL is set to "true", run the local-container-install.sh script
# to install the necessary configurations and caches.
# This is useful for local development environments where you want to keep your settings across container rebuilds.
# You can set this variable in your devcontainer.json or in your environment before starting the container.
# Example: export LOCAL_CONTAINER_INSTALL=true
if [ "${LOCAL_CONTAINER_INSTALL:-}" = true ]; then
    project-container-install.sh
fi

# 🐧 Setup Debian
debian-entrypoint.sh echo "✅ Debian setup complete."

if [ -f /usr/local/bin/desktop-x-entrypoint.sh ]; then
    /usr/local/bin/desktop-x-entrypoint.sh echo "✅ X Desktop setup successful."
fi

# Run the command
exec "$@"