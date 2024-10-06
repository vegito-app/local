#!/bin/bash

set -eu

trap "echo Exited with code $?." EXIT

ln -sfn ${PWD}/.devcontainer/bash_history ~/.bash_history

# Git
git config --global --add safe.directory .

# Vscode
cat <<'EOF' > ${PWD}/vscode.code-workspace
{
  "folders": [
    {
      "path": ".",
      "name": "project-repository"
    },
    {
      "name": "application-backend-go",
      "path": "application/backend"
    },
    {
      "name": "application-mobile-flutter",
      "path": "application/mobile",
    },
    {
      "name": "application-web-react",
      "path": "application/frontend"
    },
    {
      "name": "local-android-studio",
      "path": "local/android",
    },
    {
      "name": "local-firebase-emulators",
      "path": "local/firebase",
    },
    {
      "name": "infra-terraform",
      "path": "infra",
    },
    {
      "name": "infra-firebase-auth-func-nodejs",
      "path": "infra/gcloud/auth",
    },
    {
      "name": "infra-secrets-terraform",
      "path": "infra/gcloud/secrets",
    }
  ],
  "settings": {}
}
EOF

mkdir -p ${PWD}/backend/.vscode/

cat <<'EOF' > ${PWD}/application/backend/.vscode/launch.json
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
[ -d $EXISTING ] && mv $EXISTING ${EXISTING}_back
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
