#!/bin/bash

# This script is run on the host as devcontainer 'initializeCommand' 
# (cf. https://containers.dev/implementors/json_reference/#lifecycle-scripts)

set -euo pipefail

trap "echo Exited with code $?." EXIT

projectName=${VEGITO_PROJECT_NAME:-vegito-gcloud}
projectUser=${VEGITO_PROJECT_USER:-local-developer-id}
localDockerComposeProjectName=${VEGITO_COMPOSE_PROJECT_NAME:-$projectName-$projectUser}

DEV_GOOGLE_CLOUD_PROJECT_ID=${DEV_GOOGLE_CLOUD_PROJECT_ID:-moov-dev-439608}

GOOGLE_CLOUD_PROJECT_ID=${GOOGLE_CLOUD_PROJECT_ID:-${DEV_GOOGLE_CLOUD_PROJECT_ID}}

currentWorkingDir=${WORKING_DIR:-${PWD}}

if [ -e /dev/kvm ]; then
  KVM_GID=$(stat -c '%g' /dev/kvm)
else
  KVM_GID=""
fi

# Ensure the current working directory exists.
# Create default .env file with minimum required values to start.
localDotenvFile=${currentWorkingDir}/.devcontainer/.env
[ -f ${localDotenvFile} ] || cat <<EOF > ${localDotenvFile}
######################################################################## 
# After setting up values in this file, rebuild the local containers.  #
########################################################################
#  
# Please set the values in this section according to your personnal values.
#------------------------------------------------------- 
# 
# Trigger the local project display name in Docker Compose.
COMPOSE_PROJECT_NAME=${localDockerComposeProjectName}
# Make sure to set the correct values for using your personnal credentials IAM permissions. 
VEGITO_PROJECT_USER=${VEGITO_PROJECT_USER:-${USER:-vegito-developer-id}}
# 
GOOGLE_CLOUD_PROJECT_ID=${DEV_GOOGLE_CLOUD_PROJECT_ID}
GOOGLE_CLOUD_REGION=${GOOGLE_CLOUD_REGION}
#------------------------------------------------------- 
#----------------------------------------------------------------|
#________________________________________________________________|
EOF
