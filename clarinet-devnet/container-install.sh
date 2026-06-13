#!/bin/sh

set -euo pipefail


caches_refresh_success=false
# 🧹 Function called at the end of the script to check for success
check_success() {
    if [ $caches_refresh_success = true ]; then
        echo "♻️ Clarinet Devnet caches refreshed successfully."
    else
        echo "❌ Clarinet Devnet caches refresh failed."
    fi
}

# 🚨 Register cleanup function to run on script exit
trap check_success EXIT

# Local Container Cache
local_container_cache=${LOCAL_CLARINET_DEVNET_CONTAINER_CACHE:-${LOCAL_DIR:-${PWD}}/.containers/clarinet-devnet}
mkdir -p $local_container_cache

// TODO: Add clarinet-devnet cache

caches_refresh_success=true