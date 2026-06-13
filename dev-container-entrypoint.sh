#!/bin/bash

set -euo pipefail

project-container-entrypoint.sh echo "✅ Dev setup complete."

debian-golang-container-entrypoint.sh echo "✅ Debian Golang setup complete."

exec "$@"