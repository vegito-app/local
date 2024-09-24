#!/bin/bash

set -eu

trap "echo Exited with code $?." EXIT

ln -sfn ${PWD}/.devcontainer/bash_history ~/.bash_history

# Docker
sudo chmod o+rw /var/run/docker.sock

# Git
git config --global --add safe.directory .

# Vscode
cat <<'EOF' > ${PWD}/vscode.code-workspace
{
  "folders": [
    {
      "path": "."
    },
    {
      "path": "gcloud/infra/auth",
      "name": "auth.infra.cloud"
    },
    {
      "path": "cloud"
    },
    {
      "path": "backend"
    },
    {
      "path": "frontend"
    },
    {
      "path": "local/firebase",
      "name": "firebase.local"
    },
    {
      "name": "infra.cloud",
      "path": "gcloud/infra"
    },
    {
      "name": "infra.secrets",
      "path": "gcloud/secrets"
    }
  ],
  "settings": {}
}
EOF

mkdir -p ${PWD}/backend/.vscode/

cat <<'EOF' > ${PWD}/backend/.vscode/launch.json
{
    // Utilisez IntelliSense pour en savoir plus sur les attributs possibles.
    // Pointez pour afficher la description des attributs existants.
    // Pour plus d'informations, visitez : https://go.microsoft.com/fwlink/?linkid=830387
    "version": "0.2.0",
    "configurations": [
        {
            "name": "Launch Package",
            "type": "go",
            "request": "launch",
            "mode": "auto",
            "program": "${workspaceFolder}",
            "env": {
                "GOOGLE_CLOUD_PROJECT": "utrade-taxi-run-0",
                "FRONTEND_BUILD_DIR": "../frontend/build",
                "FRONTEND_PUBLIC_DIR": "../frontend/public",
                "UI_JAVASCRIPT_SOURCE_FILE": "../frontend/build/bundle.js",
            }
        }
    ]
}
EOF
# Vscode server/remote
DIST_VSCODE=${HOME}/.vscode-server

# Github Codespaces
if [ -v  CODESPACES ] ; then
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

# Dart Cache
DART_CACHE=${HOME}/.pub-cache
rm -rf $DART_CACHE
mkdir -p ${PWD}/.devcontainer/dart/pub-cache
ln -sf ${PWD}/.devcontainer/dart/pub-cache $DART_CACHE
