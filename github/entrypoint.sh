#!/bin/bash

# Fonction pour gérer les signaux
cleanup() {
  echo "Reçu signal, nettoyage..."
  ./config.sh remove --token $GITHUB_ACTIONS_RUNNER_TOKEN
  exit 0
}

# Installer un gestionnaire de signaux
trap cleanup SIGHUP SIGINT SIGTERM

# Exécutez la commande en arrière-plan 
/runner/config.sh \
    --url $GITHUB_ACTIONS_RUNNER_URL \
    --token $GITHUB_ACTIONS_RUNNER_TOKEN \
    --unattended \
    --name $GITHUB_ACTIONS_RUNNER_STACK-`hostname`
    
/runner/run.sh &

# Attendez la fin de l'exécution en arrière-plan
wait $!
