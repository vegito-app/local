#!/bin/bash

set -euo pipefail

# Fonction de nettoyage pour désenregistrer le runner avant de quitter
cleanup() {
  echo "🧹 Reçu signal, nettoyage..."
  ./config.sh remove --token $GITHUB_ACTIONS_RUNNER_TOKEN
  exit 0
}

# Installer un gestionnaire de signaux
trap cleanup SIGHUP SIGINT SIGTERM

export HOSTNAME=$(hostname)
export RUNNER_ALLOW_RUNASROOT=false
export RUNNER_ALLOWMULTIPLEJOBS=false

echo "🔧 Fixing ownership of /runner/_work"
sudo chown -R "github:github" /runner/_work || true

# This command should be run from the root of the actions runner.
# The remove command will unregister the runner from the repository.
# You can generate a new token here: https://github.com/organizations/vegito-app/settings/actions/runners/new
cd /runner
./config.sh \
    --url $GITHUB_ACTIONS_RUNNER_URL \
    --token $GITHUB_ACTIONS_RUNNER_TOKEN \
    --unattended \
    --name $GITHUB_ACTIONS_RUNNER_STACK-$HOSTNAME \
    --work "/runner/_work/${HOSTNAME}"
    
./run.sh &

# Attendez la fin de l'exécution en arrière-plan
wait $!
