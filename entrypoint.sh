#!/bin/sh

set -euo pipefail

trap "echo Exited with code $?." EXIT

# Bashrc
cat <<'EOF' >> ~/.bashrc
export HISTSIZE=50000
export HISTFILESIZE=100000
EOF

local_container_cache=${LOCAL_DEV_CONTAINER_CACHE:-${LOCAL_DIR:-${PWD}}/.containers/dev}
mkdir -p $local_container_cache

# Bash history
ln -sfn ${local_container_cache}/bash_history ~/.bash_history
touch ~/.bash_history

# EMACS local configuration persistence
# This allows you to persist your emacs configuration across container rebuilds.
EMACS_DIR=${HOME}/.emacs.d
[ -d $EMACS_DIR ] && mv $EMACS_DIR ${EMACS_DIR}_back
mkdir -p ${local_container_cache}/emacs
ln -sf ${local_container_cache}/emacs $EMACS_DIR


# Vscode server/remote
VSCODE_REMOTE=${HOME}/.vscode-server

# Github Codespaces
if [ -v  CODESPACES ] ; then
    VSCODE_REMOTE=${HOME}/.vscode-remote
fi

# VSCODE User data
VSCODE_REMOTE_USER_DATA=${VSCODE_REMOTE}/data/User
if [ -d $VSCODE_REMOTE_USER_DATA ] ; then 
  mv $VSCODE_REMOTE_USER_DATA ${VSCODE_REMOTE_USER_DATA}_back
  LOCAL_VSCODE_USER_GLOBAL_STORAGE=${local_container_cache}/vscode/userData/globalStorage
  mkdir -p ${LOCAL_VSCODE_USER_GLOBAL_STORAGE}
  ln -sf ${local_container_cache}/vscode/userData $VSCODE_REMOTE_USER_DATA
  ln -sf ${local_container_cache}/genieai.chatgpt-vscode ${LOCAL_VSCODE_USER_GLOBAL_STORAGE}/
fi

# GO
GOPATH=${HOME}/go
rm -rf $GOPATH
mkdir -p ${local_container_cache}/gopath
ln -sf ${local_container_cache}/gopath $GOPATH
cat <<'EOF' >> ~/.bashrc
export GOARCH=$(dpkg --print-architecture)
EOF

local_builder_image=europe-west1-docker.pkg.dev/moov-dev-439608/docker-repository-public/vegito-local:builder-latest

mkdir -p ~/.config
cat <<EOF >>  ~/.config/shell
alias hi="docker run --rm -it --privileged -v /:/host --entrypoint bash --network=host ${local_builder_image} -c 'sudo chroot /host iftop -i eno1'"
alias hh="docker run --rm -it --privileged -v /:/host --entrypoint bash --network=host ${local_builder_image} -c 'sudo chroot /host htop'"
alias h="docker run --rm -it --privileged -v /:/host --entrypoint bash --network=host ${local_builder_image} -c 'sudo chroot /host htop'"
alias b="docker run --rm -it --privileged -v /:/host --entrypoint bash --network=host ${local_builder_image} -c 'sudo chroot /host btop'"
alias r='docker run --rm -it --privileged -v /:/host --entrypoint bash --network=host ${local_builder_image} -c "sudo chroot /host"'

alias clarinet-docker='docker --host=tcp://localhost:2376'
alias clarinet-lazydocker='DOCKER_HOST=tcp://localhost:2376 lazydocker'

alias ll='ls -la'
alias l='ls -l'
alias la='ls -la'
alias lla='ls -la'
alias ls='ls --color=auto'
alias grep='grep --color=auto'
alias egrep='egrep --color=auto'
alias fgrep='fgrep --color=auto'
alias em='emacs -nw'
alias vi='vim'
alias vim='vim'
alias v='vim'
alias ld='lazydocker'
alias k='k9s'

export HISTSIZE=50000
export HISTFILESIZE=100000
EOF

cat <<EOF >> ~/.bashrc
if [ -f ~/.config/shell ]; then
    . ~/.config/shell
fi

EOF
cat <<EOF >> ~/.zshrc
if [ -f ~/.config/shell ]; then
    . ~/.config/shell
fi
EOF

# NPM
NPM_DIR=${HOME}/.npm
[ -d $NPM_DIR ] && mv $NPM_DIR ${NPM_DIR}_back
mkdir -p ${local_container_cache}/npm
ln -sf ${local_container_cache}/npm $NPM_DIR
 
# GCP
GCLOUD_CONFIG=${HOME}/.config/gcloud
mkdir -p $GCLOUD_CONFIG ${local_container_cache}/gcloud
rm -rf $GCLOUD_CONFIG
ln -sf ${local_container_cache}/gcloud $GCLOUD_CONFIG

# Dev container docker socket locally forwarded from distant dockerd host VM
socat TCP-LISTEN:2375,fork UNIX-CONNECT:/var/run/docker.sock &

# Needed with github Codespaces which can change the workspace mount specified inside docker-compose.
current_workspace=$PWD
if [ "$current_workspace" != "$HOST_PWD" ] ; then
    sudo ln -s $current_workspace $HOST_PWD 2>&1 || true
    echo "Linked current workspace $current_workspace to $HOST_PWD"
fi

if [ $# -eq 0 ]; then
  echo "[entrypoint] No command passed, entering sleep infinity to keep container alive"
  wait "${bg_pids[@]}"
else
  exec "$@"
fi