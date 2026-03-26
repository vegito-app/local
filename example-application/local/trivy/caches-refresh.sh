#!/bin/sh

set -uo pipefail


caches_refresh_success=false
# 🧹 Function called at the end of the script to check for success
check_success() {
    if [ $caches_refresh_success = true ]; then
        echo "♻️ Trivy caches refreshed successfully."
    else
        echo "❌ Trivy caches refresh failed."
    fi
}

# 🚨 Register cleanup function to run on script exit
trap check_success EXIT

local_container_cache=${LOCAL_TRIVY_CONTAINER_CACHE:-${LOCAL_DIR:-${PWD}}/.containers/trivy}
mkdir -p $local_container_cache

# Trivy config
TRIVY_CACHE=${HOME}/.cache/trivy
mkdir -p ${local_container_cache}/cache/trivy ${HOME}/.cache
rm -rf $TRIVY_CACHE
ln -sf ${local_container_cache}/cache/trivy $TRIVY_CACHE

# Bash history
BASH_HISTORY_PATH=${HOME}/.bash_history
mkdir -p ${local_container_cache}
rm -f $BASH_HISTORY_PATH
ln -sf ${local_container_cache}/.bash_history $BASH_HISTORY_PATH

caches_refresh_success=true