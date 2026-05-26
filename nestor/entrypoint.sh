#!/bin/bash

set -euo pipefail

# if [ -e /dev/kvm ]; then
#   KVM_GID_EXPECTED=$(stat -c '%g' /dev/kvm)
#   if ! id -G | tr ' ' '\n' | grep -qx "$KVM_GID_EXPECTED"; then
#     echo "❌ ERROR: android user is not in /dev/kvm group ($KVM_GID_EXPECTED)"
#     exit 1
#   fi
# fi

# Developer-friendly aliases
alias gs='git status'
alias gd='git diff'
alias gl='git log --oneline --graph --decorate'

alias ll='ls -lah'
alias py='python3'
alias k='kubectl'
alias d='docker'
alias dc='docker compose'

alias nestor-logs='tail -f /tmp/nestor.log'

if [ "${LOCAL_NESTOR_CONTAINER_INSTALL:-true}" = "true" ]; then
    nestor-container-install.sh
fi

# 🚀 Setup background services

# 🐳 Setup Docker-in-Docker (rootless)
debian-docker-entrypoint.sh echo "✅ Docker-in-Docker setup complete."

# 🖥️ Setup X Display
desktop-x-entrypoint.sh echo "✅ Desktop X setup complete."

# 🤖 Setup AI runtime
ai-entrypoint.sh echo "✅ AI runtime setup complete."

exec "$@"