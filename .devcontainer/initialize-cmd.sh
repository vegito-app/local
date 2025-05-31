#!/bin/bash

# This script is run on the host as devcontainer 'initializeCommand' 
# (cf. https://containers.dev/implementors/json_reference/#lifecycle-scripts)

set -eu

trap "echo Exited with code $?." EXIT

# Create default local .env file with minimum required values to start.
localDotenvFile=${PWD}/local/.env

[ -f $localDotenvFile ] || cat <<'EOF' > $localDotenvFile
######################################################################## 
# After setting up values in this file, rebuild the local containers.  #
########################################################################
#  
#------------------------------------------------------- 
# Please set the values in this section according to your personnal settings.
# 
# Trigger the local project display name in Docker Compose.
COMPOSE_PROJECT_NAME=moov-dev-local
# 
# Make sure to set the correct values for using your personnal credentials IAM permissions. 
PROJECT_USER=user-id-here
# 
# Can set 'MAKE_DEV_ON_START=false' to restart only the 'dev' container (skip 'make dev' in container 'dev' docker-compose command).
MAKE_DEV_ON_START=true
# 
# Android Studio (openbox - x11vnc - Xvfb)
LOCAL_ANDROID_STUDIO_ON_START=true
# 
# Set to match your screen resolution (e.g. if you are using the GUI from docker compose android-studio container).
# DISPLAY_RESOLUTION=680x1440
#
# Required if runnind E2E tests (application/tests)
LOCAL_ANDROID_STUDIO_APPIUM_EMULATOR_AVD_ON_START=true
#
# Wether to currently run the local application tests on start.
# If set to 'true', the local application tests will be run on start.
MAKE_LOCAL_APPLICATION_TESTS_RUN_ON_START=true
# 
#------------------------------------------------------- 
# The following variables are used with the local development environment.
# 
DEV_GOOGLE_CLOUD_PROJECT_ID=moov-dev-439608
BUILDER_IMAGE=europe-west1-docker.pkg.dev/${DEV_GOOGLE_CLOUD_PROJECT_ID}/docker-repository-public/${DEV_GOOGLE_CLOUD_PROJECT_ID}:builder-latest
FIREBASE_ADMINSDK_SERVICEACCOUNT_ID=projects/${DEV_GOOGLE_CLOUD_PROJECT_ID}/secrets/firebase-adminsdk-service-account-key/versions/latest
FIREBASE_PROJECT_ID=${DEV_GOOGLE_CLOUD_PROJECT_ID}
UI_CONFIG_FIREBASE_SECRET_ID=projects/${DEV_GOOGLE_CLOUD_PROJECT_ID}/secrets/firebase-config-web/versions/latest
UI_CONFIG_GOOGLEMAPS_SECRET_ID=projects/${DEV_GOOGLE_CLOUD_PROJECT_ID}/secrets/${PROJECT_USER}-googlemaps-web-api-key/versions/latest
# 
#--------------------------------------------------------
# ! Should not configure this section !
#
# The following variables are used for propagating the containers
# configurations between them each others selves.
# 
ANDROID_HOST=android-studio
APPLICATION_BACKEND_URL=http://application-backend:8080
CLARINET_RPC=http://clarinet-devnet:20443
FIREBASE_AUTH_EMULATOR_HOST=firebase-emulators:9099
FIREBASE_DATABASE_EMULATOR_HOST=firebase-emulators:9000
FIREBASE_STORAGE_EMULATOR_HOST=firebase-emulators:9199
FIRESTORE_EMULATOR_HOST=firebase-emulators:8090
VAULT_ADDR=http://vault-dev:8200
VAULT_DEV_ROOT_TOKEN_ID=root
VAULT_DEV_LISTEN_ADDRESS=http://vault-dev:8200
# 
# ! Should not configure this section !
#---------------------------------------------------------
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
                "FRONTEND_BUILD_DIR": "../frontend/build",
                "FRONTEND_PUBLIC_DIR": "../frontend/public",
                "UI_JAVASCRIPT_SOURCE_FILE": "../frontend/build/bundle.js",
                "VAULT_TOKEN": "root",
                "VAULT_ADDR": "http://vault-dev:8200",
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
            "name": "debug",
            "request": "launch",
            "args": [ "--dart-define=APPLICATION_BACKEND_URL=http://10.0.2.2:8888" ],
            "program": "lib/main.dart",
            "type": "dart"
        },
        {
            "name": "profile",
            "request": "launch",
            "args": [ "--dart-define=APPLICATION_BACKEND_URL=http://10.0.2.2:8888" ],
            "type": "dart"
        },
        {
            "name": "release",
            "request": "launch",
            "args": [ "--dart-define=APPLICATION_BACKEND_URL=http://10.0.2.2:8888" ],
            "type": "dart"
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