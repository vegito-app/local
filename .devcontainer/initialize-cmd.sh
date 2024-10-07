#!/bin/bash

set -eu

trap "echo Exited with code $?." EXIT

# 
localDotenvFile=${PWD}/local/.env
[ -f $localDotenvFile ] || cat <<'EOF' > $localDotenvFile
COMPOSE_PROJECT_NAME=utrade
BUILDER_IMAGE=us-central1-docker.pkg.dev/utrade-taxi-run-0/docker-repository-public/utrade:builder-latest
ANDROID_STUDIO_IMAGE=us-central1-docker.pkg.dev/utrade-taxi-run-0/docker-repository-public/utrade:android-studio-latest
UTRADE_GOOGLE_CLOUD_PROJECT_ID=utrade-taxi-run-0
EOF

# Vscode
workspaceFile=${PWD}/vscode.code-workspace
[ -f $workspaceFile ] || cat <<'EOF' > $workspaceFile
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

backendLaunchDebug=${PWD}/application/backend/.vscode/launch.json
if [ ! -f $backendLaunchDebug ] ;  then
mkdir -p $(dirname $backendLaunchDebug)
cat <<'EOF' > $backendLaunchDebug
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
fi
