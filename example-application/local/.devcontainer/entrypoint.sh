#!/bin/sh

set -euo pipefail

trap "echo Exited with code $?." EXIT

# Local Container Cache
local_container_cache=${local_container_cache:-${LOCAL_DIR:-${PWD}}/.containers/dev}
mkdir -p $local_container_cache

cat <<'EOF' >> ~/.bashrc
alias e="emacs"
EOF

# EMACS local configuration persistence
# This allows you to persist your emacs configuration across container rebuilds.
EMACS_DIR=${HOME}/.emacs.d
[ -d $EMACS_DIR ] && mv $EMACS_DIR ${EMACS_DIR}_back
mkdir -p ${local_container_cache}/emacs
ln -sf ${local_container_cache}/emacs $EMACS_DIR

# BASH history
ln -sfn ${local_container_cache}/bash_history ~/.bash_history

dev-entrypoint.sh "$@"