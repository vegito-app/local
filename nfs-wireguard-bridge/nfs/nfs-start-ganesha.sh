#!/bin/bash
set -euo pipefail

CONF="/etc/ganesha/ganesha.conf"

if [[ "${CODESPACES:-}" == "true" ]]; then
  echo "🌐 Using Ganesha config for GitHub Codespaces"
  CONF="/etc/ganesha/ganesha-github-codespaces.conf"
fi

echo "🟢 Starting Ganesha with $CONF"

# Runtime dirs required by ganesha
mkdir -p /var/run/ganesha /var/log/ganesha
chmod 755 /var/run/ganesha /var/log/ganesha

exec ganesha.nfsd \
  -F \
  -L STDOUT \
  -f "$CONF"