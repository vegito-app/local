#!/bin/sh

set -eu

trap "echo Exited with code $?." EXIT

# Bash history
cat <<'EOF' >> ~/.bashrc
export HISTSIZE=50000
export HISTFILESIZE=100000
EOF

# GO
GOPATH=${HOME}/go
rm -rf $GOPATH
mkdir -p ${PWD}/.caches/gopath
ln -sf ${PWD}/.caches/gopath $GOPATH
cat <<'EOF' >> ~/.bashrc
export GOARCH=$(dpkg --print-architecture)
EOF

cat <<'EOF' >> ~/.bashrc
alias hi="docker run --rm -it --privileged -v /:/host --network=host europe-west1-docker.pkg.dev/moov-dev-439608/docker-repository-public/moov-dev-439608:builder-latest sudo chroot /host iftop -i eno1"
alias hh="docker run --rm -it --privileged -v /:/host --network=host europe-west1-docker.pkg.dev/moov-dev-439608/docker-repository-public/moov-dev-439608:builder-latest sudo chroot /host htop"
alias h="docker run --rm -it --privileged -v /:/host --network=host europe-west1-docker.pkg.dev/moov-dev-439608/docker-repository-public/moov-dev-439608:builder-latest sudo chroot /host htop"
EOF

# NPM
NPM_DIR=${HOME}/.npm
[ -d $NPM_DIR ] && mv $NPM_DIR ${NPM_DIR}_back
mkdir -p ${PWD}/.caches/npm
ln -sf ${PWD}/.caches/npm $NPM_DIR
 
# GCP
GCLOUD_CONFIG=${HOME}/.config/gcloud
mkdir -p $GCLOUD_CONFIG ${PWD}/.caches/gcloud
rm -rf $GCLOUD_CONFIG
ln -sf ${PWD}/.caches/gcloud $GCLOUD_CONFIG

exec "$@"