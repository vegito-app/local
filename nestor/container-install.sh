#!/bin/sh

set -euo pipefail


caches_refresh_success=false
# 🧹 Function called at the end of the script to check for success
check_success() {
    if [ $caches_refresh_success = true ]; then
        echo "♻️ Nestor caches refreshed successfully."
    else
        echo "❌ Nestor caches refresh failed."
    fi
}

# 🚨 Register cleanup function to run on script exit
trap check_success EXIT

# Local Container Cache
local_container_cache=${LOCAL_NESTOR_CONTAINER_CACHE:-${LOCAL_DIR:-${PWD}}/.containers/nestor}
mkdir -p $local_container_cache

# local docker rootless cache 
LOCAL_DOCKERD_ROOTLESS_CACHE=${HOME}/.share/docker
mkdir -p $local_container_cache/dockerd
mkdir -p ${HOME}/.share/
ln -s $local_container_cache/dockerd $LOCAL_DOCKERD_ROOTLESS_CACHE

# Bash history
BASH_HISTORY_PATH=${HOME}/.bash_history
mkdir -p ${local_container_cache}
rm -f $BASH_HISTORY_PATH
ln -sfn ${local_container_cache}/.bash_history $BASH_HISTORY_PATH

# PIP persistence
# This allows you to persist your pip configuration across container rebuilds.
PIP_DIR=${HOME}/.cache/pip
[ -d $PIP_DIR ] && mv $PIP_DIR ${PIP_DIR}_back
mkdir -p ${local_container_cache}/pip
ln -sf ${local_container_cache}/pip $PIP_DIR


cat <<EOF >> ~/.bashrc
export HISTSIZE=50000
export HISTFILESIZE=100000
export DOCKER_HOST=unix:///run/user/${LOCAL_USER_ID:-1000}/docker.sock
export DOCKER_CONFIG=${local_container_cache}/.docker
export DOCKER_BUILDKIT=1
EOF

# Git config (optional but useful)
GIT_CONFIG_GLOBAL=${HOME}/.gitconfig
if [ -f "$GIT_CONFIG_GLOBAL" ]; then
  mkdir -p ${local_container_cache}/git
  rsync -av "$GIT_CONFIG_GLOBAL" ${local_container_cache}/git/
  rm -f "$GIT_CONFIG_GLOBAL"
  ln -s ${local_container_cache}/git/.gitconfig $GIT_CONFIG_GLOBAL
fi


AI_WORKSPACES=${AI_WORKSPACES:-/workspaces/ai}

mkdir -p ${AI_WORKSPACES}/ollama/models
mkdir -p ${AI_WORKSPACES}/ollama/cache
mkdir -p ${AI_WORKSPACES}/huggingface
mkdir -p ${AI_WORKSPACES}/torch
mkdir -p ${AI_WORKSPACES}/torch_extensions
mkdir -p ${AI_WORKSPACES}/chromadb
mkdir -p ${HOME}/.ollama
mkdir -p ${HOME}/.cache

ln -sfn ${AI_WORKSPACES}/ollama/models ${HOME}/.ollama/models
ln -sfn ${AI_WORKSPACES}/ollama/cache  ${HOME}/.ollama/cache

ln -sfn ${AI_WORKSPACES}/huggingface      ${HOME}/.cache/huggingface
ln -sfn ${AI_WORKSPACES}/torch            ${HOME}/.cache/torch
ln -sfn ${AI_WORKSPACES}/torch_extensions ${HOME}/.cache/torch_extensions
ln -sfn ${AI_WORKSPACES}/chromadb         ${HOME}/.cache/chromadb

nestor_dir=${LOCAL_NESTOR_DIR:-${PWD}}
# 🧹 Function called at the end of the script to check for success
caches_refresh_success=true