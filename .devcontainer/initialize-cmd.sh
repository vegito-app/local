#!/bin/bash

# This script is run on the host as devcontainer 'initializeCommand' (cf. https://containers.dev/implementors/json_reference/#lifecycle-scripts)

set -eu

trap "echo Exited with code $?." EXIT

# Create default local .env file with minimum required values to start.
localDotenvFile=${PWD}/dev/.env
# [ -f $localDotenvFile ] || cat <<'EOF' > $localDotenvFile
[ -f $localDotenvFile ] || cat <<'EOF' > $localDotenvFile
PROJECT_USER=david-berichon
DEV_GOOGLE_CLOUD_PROJECT_ID=moov-dev-439608
BUILDER_IMAGE=europe-west1-docker.pkg.dev/${DEV_GOOGLE_CLOUD_PROJECT_ID}/docker-repository-public/${DEV_GOOGLE_CLOUD_PROJECT_ID}:builder-latest
COMPOSE_PROJECT_NAME=moov-dev-local
FIREBASE_ADMINSDK_SERVICEACCOUNT_ID=projects/${DEV_GOOGLE_CLOUD_PROJECT_ID}/secrets/firebase-adminsdk-service-account-key/versions/1
FIREBASE_AUTH_EMULATOR_HOST=firebase-emulators:9099
FIREBASE_DATABASE_EMULATOR_HOST=http://firebase-emulators:9199
FIREBASE_FUNCTIONS_EMULATOR_HOST=http://firebase-emulators:5001
FIREBASE_PROJECT_ID=${DEV_GOOGLE_CLOUD_PROJECT_ID}
FIRESTORE_EMULATOR_HOST=firebase-emulators:8090
UI_CONFIG_FIREBASE_SECRET_ID=projects/${DEV_GOOGLE_CLOUD_PROJECT_ID}/secrets/firebase-config-web/versions/3
UI_CONFIG_GOOGLEMAPS_SECRET_ID=projects/${DEV_GOOGLE_CLOUD_PROJECT_ID}/secrets/${PROJECT_USER}-googlemaps-web-api-key/versions/1
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
      "name": "Devcontainer",
      "path": ".devcontainer"
    },
    {
      "name": "Documentation",
      "path": "docs",
    },
    {
      "name": "Application Backend - Go",
      "path": "application/backend"
    },
    {
      "name": "Application Mobile - Flutter",
      "path": "application/mobile"
    },
    {
      "name": "Application Web - React",
      "path": "application/frontend"
    },
    {
      "name": "Application - Authentication - Firebase Functions",
      "path": "application/firebase/functions"
    },
    {
      "name": "Application - Run - Terraform",
      "path": "application/run"
    }
    {
      "name": "Dev - Builder",
      "path": "dev"
    },
    {
      "name": "Dev - Firebase Emulators - Local",
      "path": "dev/firebase-emulators"
    },
    {
      "name": "Dev - Android Studio - Local",
      "path": "dev/android-studio"
    },
    {
      "name": "Dev - Vault - Local",
      "path": "dev/vault"
    },
    {
      "name": "Dev - Clarinet",
      "path": "dev/clarinet"
    }
    {
      "name": "Infrastructure - Cloud",
      "path": "infra"
    },
    {
      "name": "Infrastructure - Production - Terraform",
      "path": "infra/environments/prod"
    },
    {
      "name": "Infrastructure - Staging - Terraform",
      "path": "infra/environments/staging"
    },
    {
      "name": "Infrastructure - Dev - Terraform",
      "path": "infra/environments/dev"
    },
    {
      "name": "Infrastructure - Google Cloud - Terraform",
      "path": "infra/gcloud"
    },
    {
      "name": "Infrastructure - Vault - Production",
      "path": "infra/environments/prod/vault"
    },
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
                "VAULT_TOKEN": "root",
                "VAULT_ADDR": "http://vault-dev:8200",
            },
            "envFile": "${workspaceFolder}/../../dev/.env",
        }
    ]
}
EOF
fi

mobileLaunchDebug=${PWD}/application/mobile/.vscode/launch.json
if [ ! -f $mobileLaunchDebug ] ;  then
mkdir -p $(dirname $mobileLaunchDebug)
cat <<'EOF' > $mobileLaunchDebug
{
    // Utilisez IntelliSense pour en savoir plus sur les attributs possibles.
    // Pointez pour afficher la description des attributs existants.
    // Pour plus d'informations, visitez : https://go.microsoft.com/fwlink/?linkid=830387
    "version": "0.2.0",
    "configurations": [
        {
            "name": "mobile",
            "request": "launch",
            "type": "dart"
        },
        {
            "args": [ "--dart-define=BACKEND_URL=http://localhost:8888" ],
            "name": "mobile (profile mode)",
            "request": "launch",
            "type": "dart",
            "flutterMode": "profile"
        },
        {
            "name": "mobile (release mode)",
            "request": "launch",
            "type": "dart",
            "flutterMode": "release"
        }
    ]
}
EOF
fi

CONTAINERS_CACHE_DIR=${PWD}/dev/.containers
mkdir -p ${CONTAINERS_CACHE_DIR}

# Cache of container 'dev'
mkdir -p ${CONTAINERS_CACHE_DIR}/dev

# Copy config from host files.
if [ -d ~/.emacs.d ]; then
    rsync -av ~/.emacs.d ${CONTAINERS_CACHE_DIR}/dev/emacs
fi