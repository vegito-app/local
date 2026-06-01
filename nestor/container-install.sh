#!/bin/sh

set -euo pipefail


container_nestor_install=false
# 🧹 Function called at the end of the script to check for success
check_success() {
    if [ $container_nestor_install = true ]; then
        echo "♻️ Nestor caches refreshed successfully."
    else
        echo "❌ Nestor caches refresh failed."
    fi
}

# 🚨 Register cleanup function to run on script exit
trap check_success EXIT

# Local Container Cache
local_container_cache=${VEGITO_NESTOR_CONTAINER_CACHE:-${LOCAL_DIR:-${PWD}}/.containers/nestor}
mkdir -p $local_container_cache

NESTOR_LOGS_DIR=${NESTOR_LOGS_DIR:-${local_container_cache}}/logs
mkdir -p ${NESTOR_LOGS_DIR}

export NESTOR_LOGS_PATH=${NESTOR_LOGS_DIR}/nestor.log

# local docker rootless cache 
LOCAL_DOCKERD_ROOTLESS_CACHE=${HOME}/.local/share/docker
mkdir -p $local_container_cache/dockerd
mkdir -p ${HOME}/.local/share/
ln -sf $local_container_cache/dockerd $LOCAL_DOCKERD_ROOTLESS_CACHE

# Bash history
BASH_HISTORY_PATH=${HOME}/.bash_history
mkdir -p ${local_container_cache}
rm -f $BASH_HISTORY_PATH
ln -sfn ${local_container_cache}/.bash_history $BASH_HISTORY_PATH

# Python/pip cache
# This allows you to persist your pip configuration across container rebuilds.
PIP_CACHE_DIR=${HOME}/.cache/pip
[ -d $PIP_CACHE_DIR ] && mv $PIP_CACHE_DIR ${PIP_CACHE_DIR}_back || true
mkdir -p ${local_container_cache}/pip ${PIP_CACHE_DIR}
ln -sf ${local_container_cache}/pip $PIP_CACHE_DIR

# Bashrc enhancements for better usability
mkdir -p ~/.bashrc.d

if ! grep -q "NESTOR_BASHRC_D" ~/.bashrc; then

cat <<'EOF' >> ~/.bashrc
# NESTOR_BASHRC_D
if [ -d "${HOME}/.bashrc.d" ]; then
    for f in "${HOME}"/.bashrc.d/*.sh; do
        [ -r "$f" ] && source "$f"
    done
fi

EOF
fi

cat <<'EOF' > ~/.bashrc.d/90-nestor.sh
# Environment variables
export NESTOR_HOME=${VEGITO_NESTOR_DIR:-${PWD}}
export NESTOR_CACHE=${VEGITO_NESTOR_CONTAINER_CACHE}
export NESTOR_LOGS=${NESTOR_LOGS_PATH}

# Developer-friendly aliases
alias py='python3'

alias nestor-logs='tail -f ${NESTOR_LOGS_PATH}'

EOF


container_nestor_install=true