#!/bin/bash

set -euo pipefail

project-container-entrypoint.sh echo "✅ Debian Project setup complete."

debian-golang-container-entrypoint.sh echo "✅ Debian Golang setup complete."

exec "$@"