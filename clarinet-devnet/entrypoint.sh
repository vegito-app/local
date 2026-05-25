#!/bin/bash

set -euo pipefail

if [ "${LOCAL_CLARINET_CONTAINER_INSTALL:-true}" = "true" ]; then
    clarinet-container-install.sh
fi

debian-docker-entrypoint.sh echo "🐳 Debian Rootless Docker - Setup done"

exec "$@"