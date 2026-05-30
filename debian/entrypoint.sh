#!/bin/bash

set -euo pipefail

debian-container-install.sh

exec "$@"
