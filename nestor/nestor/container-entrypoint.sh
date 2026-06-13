#!/bin/bash

set -euo pipefail

# 🚀 Setup background services

# 🐧 Setup Debian
debian-entrypoint.sh echo "✅ Debian setup complete."

# 🐳 Setup Docker-in-Docker (rootless)
debian-docker-entrypoint.sh echo "✅ Docker-in-Docker setup complete."

# 🖥️ Setup X Display
desktop-x-entrypoint.sh echo "✅ Desktop X setup complete."

# 🤖 Setup AI runtime
ai-entrypoint.sh echo "✅ AI runtime setup complete."

for i in $(seq 1 300); do
    if [ -f /tmp/.ai-runtime-ready ]; then
        break
    fi
    echo "⏳ Waiting for AI runtime..."
    sleep 1
done

# 📱 Launch nestor compose
if [ "${VEGITO_NESTOR_CONTAINER_INSTALL:-true}" = "true" ]; then
    nestor-container-install.sh
fi

# 📊 Start logging
exec "$@"