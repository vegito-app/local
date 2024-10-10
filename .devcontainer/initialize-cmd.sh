#!/bin/bash

set -eu

trap "echo Exited with code $?." EXIT

# Create default local .env file with minimum required values to start.
localDotenvFile=${PWD}/local/.env
[ -f $localDotenvFile ] || cat <<'EOF' > $localDotenvFile
COMPOSE_PROJECT_NAME=utrade
BUILDER_IMAGE=us-central1-docker.pkg.dev/utrade-taxi-run-0/docker-repository-public/utrade:builder-latest
GOOGLE_CLOUD_PROJECT_ID=utrade-taxi-run-0
FIREBASE_PROJECT_ID=utrade-taxi-run-0
UI_CONFIG_FIREBASE_SECRET_ID=projects/402960374845/secrets/utrade-taxi-run-0-us-central1-firebase-config/versions/1
UI_CONFIG_GOOGLEMAPS_SECRET_ID=projects/402960374845/secrets/utrade-taxi-run-0-us-central1-googlemaps-api-key/versions/1
FIREBASE_ADMINSDK_SERVICEACCOUNT_ID=projects/402960374845/secrets/firebase-adminsdk-service-account-key/versions/
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
                "PORT": "8888",
                "FRONTEND_BUILD_DIR": "../frontend/build",
                "FRONTEND_PUBLIC_DIR": "../frontend/public",
                "UI_JAVASCRIPT_SOURCE_FILE": "../frontend/build/bundle.js",
            },
            "envFile": "${workspaceFolder}/../../local/.env",
        }
    ]
}
EOF
fi
