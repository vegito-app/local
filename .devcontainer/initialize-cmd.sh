#!/bin/bash

# This script is run on the host as devcontainer 'initializeCommand' 
# (cf. https://containers.dev/implementors/json_reference/#lifecycle-scripts)

set -euo pipefail

trap "echo Exited with code $?." EXIT

export WORKING_DIR=${PWD}

# Initialize .envrc file
envrcFile=${WORKING_DIR}/.devcontainer/.envrc

echo "Initializing .envrc file"
if [ ! -f ${envrcFile} ] ; then
# Note: This file is sourced by the devcontainer, do not put any commands that have side effects here.
cat <<'EOF' > ${envrcFile}
# Developer local settings keeper file.
#
# In case you want to regenerate the .env, .docker-compose-services.override.yml, etc.
# from the .envrc, you can delete them and run Devcontainer: Rebuild Container
# or run the following commands:
#   rm .env
#   rm .docker-compose-services.override.yml
#   rm .docker-compose-network.override.yml
#   rm .docker-compose-gpu.override.yml
#   rm .docker-compose-secrets.override.yml
#   rm .docker-compose-volumes.override.yml
#   rm .docker-compose-*.override.yml
#   ...
#   ./devcontainer/initialize-cmd.sh
#
# Note: This file is not sourced automatically. 
# It is used by .devcontainer/initialize-cmd.sh to generate other files.
# You can source it manually if needed.
# Example:
#   source .devcontainer/.envrc
#   dotenv.sh
#
export DEV_GOOGLE_CLOUD_PROJECT_ID=${DEV_GOOGLE_CLOUD_PROJECT_ID:-moov-dev-439608}
export VEGITO_PROJECT_USER=${VEGITO_PROJECT_USER:-david-berichon}
EOF
fi

. ${envrcFile}

echo "Initializing .env file"
${WORKING_DIR}/dotenv.sh

# Vscode
settingsFile=${PWD}/.vscode/settings.json
[ -f $settingsFile ] || cat <<'EOF' > $settingsFile
{
    // 🚫 Empêche VSCode de rechercher ou indexer ces dossiers lourds
    "search.exclude": {
        "**/node_modules": true,
        "**/dist": true,
        "**/build": true,
        "**/.git": true,
        "**/.devcontainer": false,
        "**/.containers": true,
        "**/.next": true,
        "**/.cache": true
    },
    // 💤 Désactive la surveillance en temps réel sur ces dossiers
    "files.watcherExclude": {
        "**/node_modules/**": true,
        "**/dist/**": true,
        "**/build/**": true,
        "**/.git/**": true,
        "**/.cache/**": true
    },
    // 💨 (optionnel) Réduit la charge sur la recherche globale
    "search.followSymlinks": false,
    // 🧠 (optionnel) Exclut les node_modules de l’explorateur de fichiers
    "files.exclude": {
        "**/node_modules": true
    },
    "editor.fontLigatures": false,
    "editor.formatOnSave": true,
    "editor.inlineSuggest.enabled": true,
    "explorer.confirmDelete": false,
    "genieai.enableConversationHistory": true,
    "genieai.openai.model": "gpt-4",
    "genieai.promptPrefix.addComments-enabled": false,
    "git.enabled": true,
    "go.toolsManagement.autoUpdate": true,
    "remote.autoForwardPortsSource": "process",
    "search.showLineNumbers": true,
    "terminal.integrated.profiles.linux": {
        "bash": {
            "path": "bash",
            "icon": "terminal-debian",
            "color": "terminal.ansiRed"
        }
    },
    "diffEditor.hideUnchangedRegions.enabled": false,
    "workbench.activityBar.location": "top",
    "terminal.integrated.defaultProfile.linux": "bash",
    "window.commandCenter": false,
    // "workbench.colorTheme": "Dark Theme - JetBrains IDE",
    // "workbench.colorTheme": "Best Themes - Monokai Pirokai Beach Sunset",
    "workbench.colorTheme": "Low Eye Strain Neon",
    // "workbench.colorTheme": "Dark Yellow",
    // "workbench.colorTheme": "Low Eye Strain Light Contrast",
    // "workbench.colorTheme": "Low Eye Strain Light Contrast",
    "workbench.iconTheme": "material-icon-theme",
    "material-icon-theme.folders.theme": "specific",
    "workbench.layoutControl.enabled": false,
    "zenMode.centerLayout": false,
    "zenMode.hideLineNumbers": false,
    "diffEditor.ignoreTrimWhitespace": false,
    "[jsonc]": {
        "editor.defaultFormatter": "vscode.json-language-features"
    },
    "workbench.editor.editorActionsLocation": "titleBar",
    "[dockercompose]": {
        "editor.insertSpaces": true,
        "editor.tabSize": 2,
        "editor.autoIndent": "advanced",
        "editor.defaultFormatter": "redhat.vscode-yaml"
    },
    "files.autoSave": "onFocusChange",
    "[dart]": {
        "editor.formatOnSave": true,
        "editor.formatOnType": true,
        "editor.rulers": [
            80
        ],
        "editor.selectionHighlight": false,
        "editor.tabCompletion": "onlySnippets",
        "editor.wordBasedSuggestions": "off",
    },
    "dart.flutterSdkPath": "${localWorkspaceFolder}/.containers/android-studio/flutter",
    "github-actions.workflows.pinned.workflows": [
        ".github/workflows/application-main-release.yml",
        ".github/workflows/application-dev-latest.yml"
    ],
}
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
      "name": "Local - Builder",
      "path": "local"
    },
    {
      "name": "Local - Firebase Emulators",
      "path": "firebase-emulators"
    },
    {
      "name": "Local - Android Studio",
      "path": "android-studio"
    },
    {
      "name": "Local - Vault",
      "path": "vault-dev"
    },
    {
      "name": "Local - Clarinet",
      "path": "clarinet-devnet"
    },
  ],
  "settings": {}
}
EOF


testsLaunchDebug=${PWD}/example-application/tests/.vscode/settings.json
if [ ! -f $testsLaunchDebug ] ;  then
mkdir -p $(dirname $testsLaunchDebug)
cat <<'EOF' > $testsLaunchDebug
{
    "robotcode.disableExtension": false
}
EOF
fi

backendLaunchDebug=${PWD}/example-application/backend/.vscode/launch.json
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
                "GOOGLE_APPLICATION_CREDENTIALS": "../../infra/environments/dev/google-cloud-credentials.json",
                "UI_CONFIG_FIREBASE_SECRET_ID": "projects/${GOOGLE_CLOUD_PROJECT_ID}/secrets/firebase-config-web/versions/latest",
                "UI_CONFIG_GOOGLEMAPS_SECRET_ID": "projects/${GOOGLE_CLOUD_PROJECT_ID}/secrets/googlemaps-web-api-key/versions/latest",
                "STRIPE_KEY": "projects/${GOOGLE_CLOUD_PROJECT_ID}/secrets/stripe-key/versions/latest",
                "FIREBASE_PROJECT_ID": "${GOOGLE_CLOUD_PROJECT_ID}",
                "GCLOUD_PROJECT_ID": "${GOOGLE_CLOUD_PROJECT_ID}",
                "FRONTEND_BUILD_DIR": "../frontend/build",
                "FRONTEND_PUBLIC_DIR": "../frontend/public",
                "UI_JAVASCRIPT_SOURCE_FILE": "../frontend/build-ssr/bundle.js",
                "FIRESTORE_EMULATOR_HOST": "localhost:8090",
                "VAULT_ADDR": "http://localhost:8200",
                "VAULT_TOKEN": "root",
                "VAULT_MIN_USER_RECOVERY_KEY_ROTATION_INTERVAL": "1s",
                "FIREBASE_AUTH_EMULATOR_HOST": "localhost:9099",
                "VEGETABLE_CREATED_IMAGES_MODERATOR_PUBSUB_TOPIC": "vegetable-images-created",
                "VEGETABLE_VALIDATED_IMAGES_BACKEND_PUBSUB_SUBSCRIPTION": "vegetable-images-validated-backend",
                "VEGETABLE_VALIDATED_IMAGES_CDN_PREFIX_URL": "https://validated-images-cdn-prefix-url",
            },
            "envFile": "${workspaceFolder}/../../.env",
        }
    ]
}
EOF
fi

mobileLaunchDebug=${PWD}/example-application/mobile/.vscode/launch.json
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
              "--dart-define=FIREBASE_STORAGE_PUBLIC_PREFIX=http://10.0.2.2:9199/v0/b/${GOOGLE_CLOUD_PROJECT_ID}.firebasestorage.app/o",            ]
        },
        {
            "name": "mobile (profile mode)",
            "request": "launch",
            "type": "dart",
            "flutterMode": "profile",
            "args": [
              "--dart-define=APPLICATION_BACKEND_URL=http://10.0.2.2:8080",
              "--dart-define=FIREBASE_STORAGE_PUBLIC_PREFIX=http://10.0.2.2:9199/v0/b/${GOOGLE_CLOUD_PROJECT_ID}.firebasestorage.app/o",            ]
        },
        {
            "name": "mobile (release mode)",
            "request": "launch",
            "type": "dart",
            "flutterMode": "release",
            "args": [
              "--dart-define=APPLICATION_BACKEND_URL=http://10.0.2.2:8080",
              "--dart-define=FIREBASE_STORAGE_PUBLIC_PREFIX=http://10.0.2.2:9199/v0/b/${GOOGLE_CLOUD_PROJECT_ID}.firebasestorage.app/o",            ]
        }
    ]
}
EOF
fi

CONTAINERS_CACHE_DIR=${PWD}/.containers
mkdir -p ${CONTAINERS_CACHE_DIR}

# Cache of container 'dev'
mkdir -p ${CONTAINERS_CACHE_DIR}/dev

# Copy config from host files.
if [ -d ~/.emacs.d ]; then
    rsync -av ~/.emacs.d ${CONTAINERS_CACHE_DIR}/emacs
fi