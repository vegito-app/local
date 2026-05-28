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
container_cache=${LOCAL_NESTOR_CONTAINER_CACHE:-${LOCAL_DIR:-${PWD}}/.containers/nestor}
mkdir -p $container_cache

# local docker rootless cache 
LOCAL_DOCKERD_ROOTLESS_CACHE=${HOME}/.local/share/docker
mkdir -p $container_cache/dockerd
mkdir -p ${HOME}/.local/share/
ln -sf $container_cache/dockerd $LOCAL_DOCKERD_ROOTLESS_CACHE

# Bash history
BASH_HISTORY_PATH=${HOME}/.bash_history
mkdir -p ${container_cache}
rm -f $BASH_HISTORY_PATH
ln -sfn ${container_cache}/.bash_history $BASH_HISTORY_PATH

# PIP persistence
# This allows you to persist your pip configuration across container rebuilds.
PIP_DIR=${HOME}/.cache/pip
[ -d $PIP_DIR ] && mv $PIP_DIR ${PIP_DIR}_back
mkdir -p ${container_cache}/pip
ln -sf ${container_cache}/pip $PIP_DIR

NESTOR_LOGS_DIR=${NESTOR_LOGS_DIR:-${container_cache}}/logs
mkdir -p ${NESTOR_LOGS_DIR}

export NESTOR_LOGS_PATH=${NESTOR_LOGS_DIR}/nestor.log

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
export NESTOR_HOME=${LOCAL_NESTOR_DIR:-${PWD}}
export NESTOR_CACHE=${LOCAL_NESTOR_CONTAINER_CACHE}
export NESTOR_LOGS=${NESTOR_LOGS_PATH}

# Developer-friendly aliases
alias py='python3'
alias k='kubectl'

alias nestor-logs='tail -f ${NESTOR_LOGS_PATH}'

alias tf='terraform'
alias tfi='terraform init'
alias tfp='terraform plan'
alias tfa='terraform apply'
alias tfd='terraform destroy'

alias k='kubectl'

alias kgp='kubectl get pods'
alias kgs='kubectl get svc'
alias kgd='kubectl get deploy'
alias kaf='kubectl apply -f'
alias kl='kubectl logs -f'
alias kctx='kubectl config current-context'
EOF


container_nestor_install=true