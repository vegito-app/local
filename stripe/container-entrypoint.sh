#!/bin/bash

set -euo pipefail

local-stripe-install.sh

exec "$@"