#!/bin/bash

set -euo pipefail

if [ "${VEGITO_DOCKER_DEBIAN_AI_CONTAINER_INSTALL:-true}" = "true" ]; then
  ai-container-install.sh
fi

exec "$@"