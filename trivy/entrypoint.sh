#!/bin/bash

set -euo pipefail

if [ "${LOCAL_TRIVY_CONTAINER_INSTALL:-true}" = "true" ]; then
    caches-refresh.sh
fi

exec "$@"