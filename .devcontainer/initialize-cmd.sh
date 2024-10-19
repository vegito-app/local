#!/bin/bash

set -eu

trap "echo Exited with code $?." EXIT

# Create default local .env file with minimum required values to start.
localDotenvFile=${PWD}/local/.env
# [ -f $localDotenvFile ] || cat <<'EOF' > $localDotenvFile
[ -f $localDotenvFile ] || cat <<'EOF' > $localDotenvFile
COMPOSE_PROJECT_NAME=moov
BUILDER_IMAGE=europe-west1-docker.pkg.dev/moov-438615/prod-docker-repository-public/moov-438615:builder-latest
GOOGLE_CLOUD_PROJECT_ID=moov-438615
GOOGLE_CLOUD_PROJECT_NUMBER=378762893981
FIREBASE_PROJECT_ID=moov-438615
UI_CONFIG_FIREBASE_SECRET_ID=projects/${GOOGLE_CLOUD_PROJECT_ID}/secrets/prod-firebase-web-config/versions/1
UI_CONFIG_GOOGLEMAPS_SECRET_ID=projects/${GOOGLE_CLOUD_PROJECT_ID}/secrets/prod-google-maps-api-key/versions/1
FIREBASE_ADMINSDK_SERVICEACCOUNT_ID=projects/${GOOGLE_CLOUD_PROJECT_ID}/secrets/prod-firebase-adminsdk-service-account-key/versions/1
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
