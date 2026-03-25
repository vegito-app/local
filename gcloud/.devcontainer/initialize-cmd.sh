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
${WORKING_DIR}/.devcontainer/dotenv.sh

CONTAINERS_CACHE_DIR=${PWD}/.containers
mkdir -p ${CONTAINERS_CACHE_DIR}
# Cache of container 'dev'
mkdir -p ${CONTAINERS_CACHE_DIR}/dev

# Vscode
settingsFile=${PWD}/.vscode/settings.json
[ -f $settingsFile ] || cat <<'EOF' > $settingsFile
{
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
    "terminal.integrated.defaultProfile.linux": "bash",
    "window.commandCenter": false,
    "workbench.colorTheme": "Banana Ripe",
    "workbench.iconTheme": "material-icon-theme",
    "workbench.layoutControl.enabled": false,
    "zenMode.centerLayout": false,
    "zenMode.hideLineNumbers": false,
    "diffEditor.ignoreTrimWhitespace": false,
    "[jsonc]": {
        "editor.defaultFormatter": "vscode.json-language-features"
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
    "workbench.activityBar.location": "top",
    "github-actions.workflows.pinned.workflows": [
        ".github/workflows/application-main-release.yml",
        ".github/workflows/application-dev-latest.yml",
        ".github/workflows/main.yml"
    ]
}
EOF
fi
