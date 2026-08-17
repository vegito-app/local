#!/bin/bash

set -euo pipefail

debian-dockerd-entrypoint.sh echo "🐳 Debian Rootless Docker - Setup done"

if [ "${LOCAL_CLARINET_CONTAINER_INSTALL:-true}" = "true" ]; then
    clarinet-container-install.sh
fi

exec "$@"