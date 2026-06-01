#!/bin/sh

set -uo pipefail
trap "echo Exited with code $?." EXIT


# Use a local directory to persist container caches and configurations across container rebuilds.
# You can override the default location by setting the LOCAL_DEV_CONTAINER_CACHE environment variable.
# Example: export LOCAL_DEV_CONTAINER_CACHE=/path/to/your/local/cache
# If LOCAL_DEV_CONTAINER_CACHE is not set, it will default to $LOCAL_WORKSPACE/.containers
local_container_cache=${LOCAL_DEV_CONTAINER_CACHE:-${LOCAL_WORKSPACE:-${PWD}}/.containers/dev}
mkdir -p $local_container_cache

# GO persistence 
# This allows you to persist your go workspace across container rebuilds.
GOPATH=${HOME}/go
sudo chown -R $USER:$USER $GOPATH
sudo chmod -R +rw $GOPATH
rsync -a $GOPATH/ ${local_container_cache}/gopath/
mkdir -p ${local_container_cache}/gopath
cat <<'EOF' >> ~/.bashrc
export GOARCH=$(dpkg --print-architecture)
EOF

