#!/bin/bash

set -eu

trap "echo Exited with code $?." EXIT

# Create default local .env file with minimum required values to start.
localDotenvFile=${PWD}/dev/.env
# [ -f $localDotenvFile ] || cat <<'EOF' > $localDotenvFile
[ -f $localDotenvFile ] || cat <<'EOF' > $localDotenvFile
DEV_GOOGLE_CLOUD_PROJECT_ID=moov-dev-439608
DEV_GOOGLE_CLOUD_PROJECT_USER=david-berichon
BUILDER_IMAGE=europe-west1-docker.pkg.dev/${DEV_GOOGLE_CLOUD_PROJECT_ID}/docker-repository-public/${DEV_GOOGLE_CLOUD_PROJECT_ID}:builder-latest
COMPOSE_PROJECT_NAME=moov-dev-local
FIREBASE_ADMINSDK_SERVICEACCOUNT_ID=projects/${DEV_GOOGLE_CLOUD_PROJECT_ID}/secrets/firebase-adminsdk-service-account-key/versions/1
FIREBASE_AUTH_EMULATOR_HOST=firebase-emulators:9099
FIREBASE_DATABASE_EMULATOR_HOST=http://firebase-emulators:9199
FIREBASE_FUNCTIONS_EMULATOR_HOST=http://firebase-emulators:5001
FIREBASE_PROJECT_ID=${DEV_GOOGLE_CLOUD_PROJECT_ID}
FIRESTORE_EMULATOR_HOST=firebase-emulators:8090
UI_CONFIG_FIREBASE_SECRET_ID=projects/${DEV_GOOGLE_CLOUD_PROJECT_ID}/secrets/firebase-config-web/versions/3
UI_CONFIG_GOOGLEMAPS_SECRET_ID=projects/${DEV_GOOGLE_CLOUD_PROJECT_ID}/secrets/${DEV_GOOGLE_CLOUD_PROJECT_USER}-googlemaps-web-api-key/versions/1
EOF

# Vscode
workspaceFile=${PWD}/vscode.code-workspace
[ -f $workspaceFile ] || cat <<'EOF' > $workspaceFile
{
  "folders": [
    {
      "path": ".",
      "name": "Project"
    },
    {
      "name": "Documentation",
      "path": "docs",
    },
    {
      "name": "Application - Backend",
      "path": "application/backend"
    },
    {
      "name": "Application - Mobile",
      "path": "application/mobile"
    },
    {
      "name": "Application - Web",
      "path": "application/frontend"
    },
    {
      "name": "Androïd Studio",
      "path": "android-studio"
    },
    {
      "name": "Firebase Emulators",
      "path": "firebase/emulators"
    },
    {
      "name": "Dev - Builder",
      "path": "dev"
    },
    {
      "name": "Infrastructure",
      "path": "infra"
    },
    {
      "name": "auth-func-firebase-infra-nodejs",
      "path": "infra/gcloud/auth"
    },
    {
      "name": "Devcontainer",
      "path": ".devcontainer"
    },
    {
      "name": "Infrastructure - Production",
      "path": "infra/environments/prod"
    },
    {
      "name": "Infrastructure - Staging",
      "path": "infra/environments/staging"
    },
    {
      "name": "Infrastructure - Dev",
      "path": "infra/environments/dev"
    },
    {
      "name": "Cloud - GCP",
      "path": "infra/gcloud"
    },
    {
      "name": "Clarinet/Devnet",
      "path": "clarinet"
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