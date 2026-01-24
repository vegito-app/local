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

# Vscode server/remote
VSCODE_REMOTE="${HOME}/.vscode-server"
mkdir -p "$VSCODE_REMOTE/bin" "$VSCODE_REMOTE/extensions"
# -------------------------------------------------------------------
# VS Code Server prewarm (bin + extensions)
# -------------------------------------------------------------------

VSCODE_COMMIT="${VSCODE_COMMIT:-c9d77990917f3102ada88be140d28b038d1dd7c7}"

SRC_BASE="/home/vegito/.vscode-server"
SRC_BIN="${SRC_BASE}/bin/${VSCODE_COMMIT}"
SRC_EXT="${SRC_BASE}/extensions"

for USER_HOME in \
  /home/clarinet \
  /home/android \
  ; do
  TARGET_BASE="${USER_HOME}/.vscode-server"

  mkdir -p "${TARGET_BASE}/bin/${VSCODE_COMMIT}" "${TARGET_BASE}/extensions"

  # Server binaries (idempotent)
  if [ -d "$SRC_BIN" ] && [ ! -d "${TARGET_BASE}/bin/${VSCODE_COMMIT}/node_modules" ]; then
    rsync -a "$SRC_BIN/" "${TARGET_BASE}/bin/${VSCODE_COMMIT}/"
  fi

  # Extensions (heavy but worth it)
  # if [ -d "$SRC_EXT" ]; then
  #   rsync -a "$SRC_EXT/" "${TARGET_BASE}/extensions/"
  # fi
done

# -------------------------------------------------------------------
# VS Code Server - Install .vsix extensions
# -------------------------------------------------------------------
VSIX_DIR="/opt/vscode/vsix"
EXT_DIR="${HOME}/.vscode-server/extensions"

if [ -d "$VSIX_DIR" ]; then
  for VSIX in "$VSIX_DIR"/*.vsix; do
    code-server \
      --extensions-dir "$EXT_DIR" \
      --install-extension "$VSIX" \
      --force
  done
fi

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
    # persist locally (gitignored)
    ln -sf ${local_container_cache}/vscode/userData $VSCODE_REMOTE_USER_DATA
    # versionned folder for gpt chat logging (folder ${local_container_cache}/genieai.chatgpt-vscode)
    ln -sf ${local_container_cache}/genieai.chatgpt-vscode ${LOCAL_VSCODE_USER_GLOBAL_STORAGE}/
fi

dev-entrypoint.sh "$@"