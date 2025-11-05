#!/bin/sh

set -uo pipefail
trap "echo Exited with code $?." EXIT

# Bashrc enhancements for better usability
cat <<'EOF' >> ~/.bashrc
export HISTSIZE=50000
export HISTFILESIZE=100000
EOF

# Use a local directory to persist container caches and configurations across container rebuilds.
# You can override the default location by setting the LOCAL_DEV_CONTAINER_CACHE environment variable.
# Example: export LOCAL_DEV_CONTAINER_CACHE=/path/to/your/local/cache
# If LOCAL_DEV_CONTAINER_CACHE is not set, it will default to $LOCAL_DIR/.containers
local_container_cache=${LOCAL_DEV_CONTAINER_CACHE:-${LOCAL_DIR:-${PWD}}/.containers/dev}
mkdir -p $local_container_cache

# Bash history persistence
# This allows you to keep your bash history across container rebuilds.
ln -sfn ${local_container_cache}/bash_history ~/.bash_history
touch ~/.bash_history

# EMACS local configuration persistence
# This allows you to persist your emacs configuration across container rebuilds.
EMACS_DIR=${HOME}/.emacs.d
[ -d $EMACS_DIR ] && mv $EMACS_DIR ${EMACS_DIR}_back
mkdir -p ${local_container_cache}/emacs
ln -sf ${local_container_cache}/emacs $EMACS_DIR


# Vscode server/remote persistence
VSCODE_REMOTE=${HOME}/.vscode-server

# Github Codespaces specific
if [ -v  CODESPACES ] ; then
    VSCODE_REMOTE=${HOME}/.vscode-remote
fi

# VSCODE User data persistence
# This allows you to persist your vscode user data across container rebuilds.
# Note: This will not persist your extensions, only your user settings and configurations.
# Extensions are typically reinstalled via the devcontainer.json file.
[ -d $VSCODE_REMOTE ] && mv $VSCODE_REMOTE ${VSCODE_REMOTE}_back
mkdir -p ${local_container_cache}/vscode/userData
mkdir -p ${local_container_cache}/vscode/extensions
mkdir -p ${VSCODE_REMOTE}
ln -sf ${local_container_cache}/vscode/extensions ${VSCODE_REMOTE}/extensions
VSCODE_REMOTE_USER_DATA=${VSCODE_REMOTE}/data/User
if [ -d $VSCODE_REMOTE_USER_DATA ] ; then 
  mv $VSCODE_REMOTE_USER_DATA ${VSCODE_REMOTE_USER_DATA}_back
  LOCAL_VSCODE_USER_GLOBAL_STORAGE=${local_container_cache}/vscode/userData/globalStorage
  mkdir -p ${LOCAL_VSCODE_USER_GLOBAL_STORAGE}
  ln -sf ${local_container_cache}/vscode/userData $VSCODE_REMOTE_USER_DATA
  ln -sf ${local_container_cache}/genieai.chatgpt-vscode ${LOCAL_VSCODE_USER_GLOBAL_STORAGE}/
fi

# GO persistence 
# This allows you to persist your go workspace across container rebuilds.
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
# Aliases to use host tools from inside the container
# These aliases use docker to run the tools in a privileged container with access to the host filesystem and network.
# This allows you to use tools like htop, iftop, btop, etc. on the host system from inside the container.
# Make sure to replace ${local_builder_image} with the actual image name if it's different.
alias hi="docker run --rm -it --privileged -v /:/host --entrypoint bash --network=host ${local_builder_image} -c 'sudo chroot /host iftop -i eno1'"
alias hh="docker run --rm -it --privileged -v /:/host --entrypoint bash --network=host ${local_builder_image} -c 'sudo chroot /host htop'"
alias h="docker run --rm -it --privileged -v /:/host --entrypoint bash --network=host ${local_builder_image} -c 'sudo chroot /host htop'"
alias b="docker run --rm -it --privileged -v /:/host --entrypoint bash --network=host ${local_builder_image} -c 'sudo chroot /host btop'"
alias r='docker run --rm -it --privileged -v /:/host --entrypoint bash --network=host ${local_builder_image} -c "sudo chroot /host"'

# Aliases to use docker and lazydocker with the docker daemon of the host system
# These aliases forward the docker commands to the host's docker daemon via TCP.
# Make sure the host's docker daemon is configured to listen on TCP port 2376.
# You can set this up by adding the following to your host's /etc/docker/daemon.json:
# {
#   "hosts": ["unix:///var/run/docker.sock", "tcp://0.0.0.0:2376"]
# }
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

# NPM persistence
# This allows you to persist your npm configuration across container rebuilds.
NPM_DIR=${HOME}/.npm
[ -d $NPM_DIR ] && mv $NPM_DIR ${NPM_DIR}_back
mkdir -p ${local_container_cache}/npm
ln -sf ${local_container_cache}/npm $NPM_DIR

# GCP persistence
# This allows you to persist your gcloud configuration across container rebuilds.
GCLOUD_CONFIG=${HOME}/.config/google-cloud
mkdir -p $GCLOUD_CONFIG ${local_container_cache}/google-cloud
rm -rf $GCLOUD_CONFIG
ln -sf ${local_container_cache}/google-cloud $GCLOUD_CONFIG
