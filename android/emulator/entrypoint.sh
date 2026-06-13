#!/bin/bash

set -euo pipefail

# 🚀 Setup background services

# 🐧 Setup Debian
debian-entrypoint.sh echo "✅ Debian setup complete."

# 🐳 Setup Docker-in-Docker (rootless)
debian-docker-entrypoint.sh echo "✅ Docker-in-Docker setup complete."

# 🖥️ Setup X Display
desktop-x-entrypoint.sh echo "✅ Desktop X setup complete."

if [ -e /dev/kvm ]; then
  KVM_GID_EXPECTED=$(stat -c '%g' /dev/kvm)
  if ! id -G | tr ' ' '\n' | grep -qx "$KVM_GID_EXPECTED"; then
    echo "❌ ERROR: android user is not in /dev/kvm group ($KVM_GID_EXPECTED)"
    exit 1
  fi
fi

# Developer-friendly aliases
alias gs='git status'
alias gb='git branch'
alias gd='git diff'
alias gl='git log --oneline --graph --decorate'
alias flutter-clean='flutter clean && rm -rf .dart_tool .packages pubspec.lock build'
alias run-android='flutter run -d android'

# Run the command inside the container
exec "$@"

