#!/bin/sh

set -euo pipefail

trap "echo Exited with code $?." EXIT

# Local container installation script to setup persistent configurations and caches.
# If LOCAL_CONTAINER_INSTALL is set to "true", run the local-container-install.sh script
# to install the necessary configurations and caches.
# This is useful for local development environments where you want to keep your settings across container rebuilds.
# You can set this variable in your devcontainer.json or in your environment before starting the container.
# Example: export LOCAL_CONTAINER_INSTALL=true
if [ "${LOCAL_CONTAINER_INSTALL:-}" = true ]; then
    local-container-install.sh
fi

# Listening docker socket at local TCP 2375 will allow vscode to forward it to your remote editor.
# (localhost:2375 will be used if it is available on your editor machine or another one will be tried by vscode).
# This is working both on Github Codespaces and on local vscode with the "Remote - Containers" extension.
# Port forwarding is automatically done by vscode when a process is listening.
# This is secure as the socket is only accessible from inside the container and you have an ssh or vscode remote session.
socat TCP-LISTEN:2375,fork UNIX-CONNECT:/var/run/docker.sock &
bg_pids=($!)

# Pay attention to use a path that is mounted inside the container. Because you want to edit files from your host machine.
# This is typically a workspace folder mounted inside the container.
# By default, we are using the current working directory (PWD) as the workspace folder.
# You can override the default location by setting the LOCAL_WORKSPACE environment variable.
# Example: export LOCAL_WORKSPACE=/path/to/your/local/workspace
current_workspace=$PWD

# Needed with Github Codespaces which can change the workspace mount specified inside docker-compose.yml working directory
# to match the one used by Codespaces.
# You can ignore this with local vscode "Remote - Containers" extension which is using the same workspace mount as specified
# inside docker-compose.yml working directory.
# You can override the default location by setting the LOCAL_WORKSPACE environment variable.
# Example: export LOCAL_WORKSPACE=/path/to/your/local/workspace
LOCAL_WORKSPACE=${LOCAL_WORKSPACE:-/workspaces/vegito-app/local}
if [ "$current_workspace" != "$LOCAL_WORKSPACE" ] ; then
    sudo ln -s $current_workspace $LOCAL_WORKSPACE 2>&1 || true
    echo "Linked current workspace $current_workspace to $LOCAL_WORKSPACE"
fi

if [ $# -eq 0 ]; then
  echo "[entrypoint] No command passed, entering sleep infinity to keep container alive"
  wait "${bg_pids[@]}"
else
  exec "$@"
fi