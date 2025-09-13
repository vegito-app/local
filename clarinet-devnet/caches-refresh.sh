#!/bin/sh

set -euo pipefail


caches_refresh_success=false
# 🧹 Function called at the end of the script to check for success
check_success() {
    if [ $caches_refresh_success = true ]; then
        echo "♻️ Android Studio caches refreshed successfully."
    else
        echo "❌ Android Studio caches refresh failed."
    fi
}

# 🚨 Register cleanup function to run on script exit
trap check_success EXIT

# Local Container Cache
local_container_cache=${LOCAL_CLARINET_DEVNET_CONTAINER_CACHE:-${LOCAL_DIR:-${PWD}}/.containers/clarinet-devnet}
mkdir -p $local_container_cache

# local docker rootless cache 
LOCAL_DOCKERD_ROOTLESS_CACHE=${HOME}/.share/docker
mkdir -p $local_container_cache/dockerd
mkdir -p ${HOME}/.share/
ln -s $local_container_cache/dockerd $LOCAL_DOCKERD_ROOTLESS_CACHE

# vscode-server config
CLARINET_DEVNET_VSCODE_SERVER=${HOME}/.vscode-server
mkdir -p ${local_container_cache}/.vscode-server
rm -rf $CLARINET_DEVNET_VSCODE_SERVER
ln -sf ${local_container_cache}/.vscode-server $CLARINET_DEVNET_VSCODE_SERVER

# Bash history
BASH_HISTORY_PATH=${HOME}/.bash_history
mkdir -p ${local_container_cache}
rm -f $BASH_HISTORY_PATH
ln -sfn ${local_container_cache}/.bash_history $BASH_HISTORY_PATH

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

# CAUSES UNFORTUNATE START WITH INCONSISTENT ALREADY RUNNING STATE
# # Persist VS Code settings (optional)
# VSCODE_SETTINGS=${HOME}/.config/Code
# mkdir -p $LOCAL_ANDROID_CONTAINER_EXEC/vscode
# if [ -d "$VSCODE_SETTINGS" ]; then
#   rsync -av "$VSCODE_SETTINGS" $LOCAL_ANDROID_CONTAINER_EXEC/vscode/
#   rm -rf "$VSCODE_SETTINGS"
# fi
# ln -sf $LOCAL_ANDROID_CONTAINER_EXEC/vscode/Code $VSCODE_SETTINGS

clarinet_devnet_dir=${LOCAL_CLARINET_DEVNET_DIR:-${PWD}}

# Create symlinks for scripts
for script in `ls ${clarinet_devnet_dir}/*.sh`; \
do
    filename=${clarinet_devnet_dir}/${script}
    if [ -f "${filename}" ]; then
        echo "Linking ${script} to /usr/local/bin/${script} for easy access"
        sudo ln -sf ${filename} /usr/local/bin/${script}
    fi
done

caches_refresh_success=true