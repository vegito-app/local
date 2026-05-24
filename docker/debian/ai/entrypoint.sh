#!/bin/bash

set -euo pipefail

ai-container-install.sh

exec "$@"