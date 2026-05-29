#!/bin/sh

set -euo pipefail

trap "echo Exited with code $?." EXIT

devcontainer-install.sh

dev-entrypoint.sh echo "✅ Dev setup complete."

# Run the command
exec "$@"