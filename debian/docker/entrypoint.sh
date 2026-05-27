#!/bin/bash

set -euo pipefail

debian-docker-install.sh

exec "$@"