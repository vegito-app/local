#!/bin/bash

# This script is run on the host as devcontainer 'initializeCommand' 
# (cf. https://containers.dev/implementors/json_reference/#lifecycle-scripts)

set -eu

trap "echo Exited with code $?." EXIT

# initialize local/.env file
${PWD}/local/dotenv.sh

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
      "name": "Application Images - Cleaner - Go",
      "path": "application/images/cleaner"
    },
    {
      "name": "Application Images - Moderator - Go",
      "path": "application/images/moderator"
    },
    {
      "name": "Application - Authentication - Firebase Functions",
      "path": "application/firebase/functions"
    },
    {
      "name": "Application - Run - Terraform",
      "path": "application/run"
    },
    {
      "name": "Local - Builder",
      "path": "local"
    },
    {
      "name": "Local - Firebase Emulators",
      "path": "local/firebase-emulators"
    },
    {
      "name": "Local - Android Studio",
      "path": "local/android-studio"
    },
    {
      "name": "Local - Vault",
      "path": "local/vault-dev"
    },
    {
      "name": "Local - Clarinet",
      "path": "local/clarinet-devnet"
    },
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
                "GOOGLE_APPLICATION_CREDENTIALS": "../../infra/environments/dev/gcloud-credentials.json",
                "UI_CONFIG_FIREBASE_SECRET_ID": "projects/moov-dev-439608/secrets/firebase-config-web/versions/latest",
                "UI_CONFIG_GOOGLEMAPS_SECRET_ID": "projects/moov-dev-439608/secrets/googlemaps-web-api-key/versions/latest",
                "STRIPE_KEY": "projects/moov-dev-439608/secrets/stripe-key/versions/latest",
                "FIREBASE_PROJECT_ID": "moov-dev-439608",
                "GCLOUD_PROJECT_ID": "moov-dev-439608",
                "FRONTEND_BUILD_DIR": "../frontend/build",
                "FRONTEND_PUBLIC_DIR": "../frontend/public",
                "UI_JAVASCRIPT_SOURCE_FILE": "../frontend/build/bundle.js",
                "FIRESTORE_EMULATOR_HOST": "localhost:8090",
                "VAULT_ADDR": "http://localhost:8200",
                "VAULT_TOKEN": "root",
                "VAULT_MIN_USER_RECOVERY_KEY_ROTATION_INTERVAL": "1s",
                "FIREBASE_AUTH_EMULATOR_HOST": "localhost:9099",
                "VEGETABLE_CREATED_IMAGES_MODERATOR_PUBSUB_TOPIC": "vegetable-images-created",
                "VEGETABLE_VALIDATED_IMAGES_BACKEND_PUBSUB_SUBSCRIPTION": "vegetable-images-validated-backend",
                "VEGETABLE_VALIDATED_IMAGES_CDN_PREFIX_URL": "https://validated-images-cdn-prefix-url",
            },
            "envFile": "${workspaceFolder}/../../local/.env",
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
            "name": "mobile (debug mode)",
            "request": "launch",
            "type": "dart",
            "flutterMode": "debug",
            "args": [
              "--dart-define=APPLICATION_BACKEND_URL=http://10.0.2.2:8888",
              "--dart-define=FIREBASE_STORAGE_PUBLIC_PREFIX=http://10.0.2.2:9199/v0/b/moov-dev-439608.firebasestorage.app/o",            ]
        },
        {
            "name": "mobile (profile mode)",
            "request": "launch",
            "type": "dart",
            "flutterMode": "profile",
            "args": [
              "--dart-define=APPLICATION_BACKEND_URL=http://10.0.2.2:8080",
              "--dart-define=FIREBASE_STORAGE_PUBLIC_PREFIX=http://10.0.2.2:9199/v0/b/moov-dev-439608.firebasestorage.app/o",            ]
        },
        {
            "name": "mobile (release mode)",
            "request": "launch",
            "type": "dart",
            "flutterMode": "release",
            "args": [
              "--dart-define=APPLICATION_BACKEND_URL=http://10.0.2.2:8080",
              "--dart-define=FIREBASE_STORAGE_PUBLIC_PREFIX=http://10.0.2.2:9199/v0/b/moov-dev-439608.firebasestorage.app/o",            ]
        }
    ]
}
EOF
fi

CONTAINERS_CACHE_DIR=${PWD}/local/.containers
mkdir -p ${CONTAINERS_CACHE_DIR}

# Cache of container 'dev'
mkdir -p ${CONTAINERS_CACHE_DIR}/dev

# Copy config from host files.
if [ -d ~/.emacs.d ]; then
    rsync -av ~/.emacs.d ${CONTAINERS_CACHE_DIR}/local/emacs
fi