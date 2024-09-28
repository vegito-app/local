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
      "path": ".",
      "name": "project-root"
    },
    {
      "path": "infra/gcloud/auth",
      "name": "auth-func-infra"
    },
    {
      "path": "infra"
    },
    {
      "name": "backend-go",
      "path": "backend"
    },
    {
      "name": "frontend-react",
      "path": "frontend"
    },
    {
      "path": "local/firebase",
      "name": "firebase-emulators"
    },
    {
      "name": "secrets-infra",
      "path": "infra/gcloud/secrets"
    },
    {
      "name": "car2go-application-flutter",
      "path": "application/car2go",
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
VSCODE_REMOTE=${HOME}/.vscode-server

# Github Codespaces
if [ -v  CODESPACES ] ; then
    VSCODE_REMOTE=${HOME}/.vscode-remote
fi

# VSCODE User data
VSCODE_USER_DATA=${VSCODE_REMOTE}/data/User
[ -d $VSCODE_USER_DATA ] && mv $VSCODE_USER_DATA ${VSCODE_USER_DATA}_back
mkdir -p ${PWD}/.devcontainer/vscode/userData
ln -sf ${PWD}/.devcontainer/vscode/userData $VSCODE_USER_DATA
# mkdir -p ${PWD}/.devcontainer/vscode/userData/globalStorage
# 
# genieai-chatgpt-vscode
VSCODE_GLOBAL_STORAGE=${PWD}/.devcontainer/vscode/userData/globalStorage
EXISTING=${VSCODE_GLOBAL_STORAGE}/genieai.chatgpt-vscode
[ -d $EXISTING ] || echo $EXISTING && mv $EXISTING ${EXISTING}_back
ln -sf ${PWD}/.devcontainer/genieai.chatgpt-vscode ${VSCODE_GLOBAL_STORAGE}

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
[ -d $NPM_DIR ] && mv $NPM_DIR ${NPM_DIR}_back
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
