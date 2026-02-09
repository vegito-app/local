#!/bin/sh

set -euo pipefail


caches_refresh_success=false
# 🧹 Function called at the end of the script to check for success
check_success() {
    if [ $caches_refresh_success = true ]; then
        echo "♻️ Robot Framework caches refreshed successfully."
    else
        echo "❌ Robot Framework caches refresh failed."
    fi
}

# 🚨 Register cleanup function to run on script exit
trap check_success EXIT

# Local Container Cache
local_container_cache=${LOCAL_ROBOTFRAMEWORK_CONTAINER_CACHE:-${LOCAL_DIR:-${PWD}}/.containers/robotframework}
mkdir -p $local_container_cache

# Python/pip cache
PIP_CACHE_DIR=${HOME}/.cache/pip
[ -d $PIP_CACHE_DIR ] && mv $PIP_CACHE_DIR ${PIP_CACHE_DIR}_back || true
mkdir -p ${local_container_cache}/pip ${PIP_CACHE_DIR}
ln -sf ${local_container_cache}/pip $PIP_CACHE_DIR

# Bash history
BASH_HISTORY_PATH=${HOME}/.bash_history
mkdir -p ${local_container_cache}
rm -f $BASH_HISTORY_PATH
ln -sfn ${local_container_cache}/.bash_history $BASH_HISTORY_PATH

cat <<EOF >> ~/.bashrc
export HISTSIZE=50000
export HISTFILESIZE=100000
EOF

# Git config (optional but useful)
GIT_CONFIG_GLOBAL=${HOME}/.gitconfig
if [ -f "$GIT_CONFIG_GLOBAL" ]; then
  mkdir -p ${local_container_cache}/git
  rsync -av "$GIT_CONFIG_GLOBAL" ${local_container_cache}/git/
  rm -f "$GIT_CONFIG_GLOBAL"
  ln -s ${local_container_cache}/git/.gitconfig $GIT_CONFIG_GLOBAL
fi

caches_refresh_success=true