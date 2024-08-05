#!/bin/bash

# Docker
sudo chmod o+rw /var/run/docker.sock

# Bash history
ln -sfn ${PWD}/.devcontainer/bash_history ~/.bash_history
cat <<'EOF' >> ~/.bashrc
export HISTSIZE=50000
export HISTFILESIZE=100000
EOF

DIST_VSCODE=${HOME}/.vscode-server

# Github Codespaces
if [ ${CODESPACES} ] ; then
    DIST_VSCODE=${HOME}/.vscode-remote
fi

# VSCODE User data
VSCODE_USER_DATA=${DIST_VSCODE}/data/User
rm -rf $VSCODE_USER_DATA
mkdir -p ${PWD}/.devcontainer/vscode/userData
ln -sf ${PWD}/.devcontainer/vscode/userData $VSCODE_USER_DATA

# GO
GOPATH=${HOME}/go
rm -rf $GOPATH
mkdir -p ${PWD}/.devcontainer/gopath
ln -sf ${PWD}/.devcontainer/gopath $GOPATH
cat <<'EOF' >> ~/.bashrc
export GOARCH=$(dpkg --print-architecture)
EOF

# NPM
NPM_DIR=${HOME}/.npm
rm -rf $NPM_DIR
mkdir -p ${PWD}/.devcontainer/npm
ln -sf ${PWD}/.devcontainer/npm $NPM_DIR
 
# GCP
GCLOUD_CONFIG=${HOME}/.config/gcloud
mkdir -p $GCLOUD_CONFIG ${PWD}/.devcontainer/gcloud
rm -rf $GCLOUD_CONFIG
ln -sf ${PWD}/.devcontainer/gcloud $GCLOUD_CONFIG

cat <<'EOF' >> ~/.bashrc
export REACT_APP_UTRADE_FIREBASE_API_KEY=${UTRADE_FIREBASE_API_KEY}
export REACT_APP_UTRADE_FIREBASE_AUTH_DOMAIN=${UTRADE_FIREBASE_AUTH_DOMAIN}
export REACT_APP_UTRADE_FIREBASE_DATABASE_URL=${UTRADE_FIREBASE_DATABASE_URL}
export REACT_APP_UTRADE_FIREBASE_PROJECT_ID=${UTRADE_FIREBASE_PROJECT_ID}
export REACT_APP_UTRADE_FIREBASE_STORAGE_BUCKET=${UTRADE_FIREBASE_STORAGE_BUCKET}
export REACT_APP_UTRADE_FIREBASE_MESSAGING_SENDER_ID=${UTRADE_FIREBASE_MESSAGING_SENDER_ID}
export REACT_APP_UTRADE_FIREBASE_APP_ID=${UTRADE_FIREBASE_APP_ID}
EOF
