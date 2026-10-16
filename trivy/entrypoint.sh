#!/bin/bash

set -euo pipefail

if [ "${LOCAL_TRIVY_CONTAINER_INSTALL:-true}" = "true" ]; then
    trivy-container-install.sh
fi

exec trivy "$@"