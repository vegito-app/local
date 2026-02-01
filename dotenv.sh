#!/bin/bash

# This script is run on the host as devcontainer 'initializeCommand' 
# (cf. https://containers.dev/implementors/json_reference/#lifecycle-scripts)

set -euo pipefail

trap "echo Exited with code $?." EXIT

projectName=${VEGITO_PROJECT_NAME:-vegito-example-application}
projectUser=${VEGITO_PROJECT_USER:-local-developer-id}
localDockerComposeProjectName=${VEGITO_COMPOSE_PROJECT_NAME:-$projectName-$projectUser}

DEV_GOOGLE_CLOUD_PROJECT_ID=${DEV_GOOGLE_CLOUD_PROJECT_ID:-moov-dev-439608}

GOOGLE_CLOUD_PROJECT_ID=${GOOGLE_CLOUD_PROJECT_ID:-${DEV_GOOGLE_CLOUD_PROJECT_ID}}

currentWorkingDir=${WORKING_DIR:-${PWD}}
# Ensure the current working directory exists.
# Create default .env file with minimum required values to start.
localDotenvFile=${currentWorkingDir}/.env
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
LOCAL_VERSION=${LOCAL_VERSION}
LOCAL_BUILDER_IMAGE=${LOCAL_BUILDER_IMAGE:-europe-west1-docker.pkg.dev/${GOOGLE_CLOUD_PROJECT_ID}/docker-repository-public/vegito-local:builder-${LOCAL_VERSION}}
#------------------------------------------------------- 
# The following resources are used for the local development environment:
# 
GOOGLE_CLOUD_PROJECT_ID=${DEV_GOOGLE_CLOUD_PROJECT_ID}
DEV_GOOGLE_IDP_OAUTH_KEY_SECRET_ID=projects/${DEV_GOOGLE_CLOUD_PROJECT_ID}/secrets/google-idp-oauth-key/versions/latest
DEV_GOOGLE_IDP_OAUTH_CLIENT_ID_SECRET_ID=projects/${DEV_GOOGLE_CLOUD_PROJECT_ID}/secrets/google-idp-oauth-client-id/versions/latest
DEV_STRIPE_KEY_SECRET_SECRET_ID=projects/${DEV_GOOGLE_CLOUD_PROJECT_ID}/secrets/stripe-key/versions/latest
# 
FIREBASE_ADMINSDK_SERVICEACCOUNT_ID=projects/${GOOGLE_CLOUD_PROJECT_ID}/secrets/firebase-adminsdk-service-account-key/versions/latest
FIREBASE_PROJECT_ID=${GOOGLE_CLOUD_PROJECT_ID}
# 
UI_CONFIG_FIREBASE_SECRET_ID=projects/${GOOGLE_CLOUD_PROJECT_ID}/secrets/firebase-config-web/versions/latest
UI_CONFIG_GOOGLEMAPS_SECRET_ID=projects/${GOOGLE_CLOUD_PROJECT_ID}/secrets/david-berichon-googlemaps-web-api-key/versions/latest
# 
FIREBASE_STORAGE_PUBLIC_PREFIX=https://firebasestorage.googleapis.com/v0/b/${GOOGLE_CLOUD_PROJECT_ID}.appspot.com/o
CDN_PUBLIC_PREFIX=https://cdn.mon-backend.com  # ton CDN public GCS
# 
STRIPE_KEY_PUBLISHABLE_SECRET_ID=projects/${GOOGLE_CLOUD_PROJECT_ID}/secrets/stripe-key/versions/latest
STRIPE_KEY_SECRET_SECRET_ID=projects/${GOOGLE_CLOUD_PROJECT_ID}/secrets/stripe-key/versions/latest
# 
GITHUB_ACTIONS_RUNNER_URL=https://github.com/vegito-app
#----------------------------------------------------------------|
#----------------------------------------------------------------|
# The following variables are used for propagating the containers|
# configurations between them each others selves.
#                                                                
ANDROID_HOST=android-studio
VEGITO_EXAMPLE_APPLICATION_BACKEND_DEBUG_URL=http://example-application-backend:8888
VEGITO_EXAMPLE_APPLICATION_BACKEND_URL=http://example-application-backend:8080
CLARINET_RPC=http://clarinet-devnet:20443
FIREBASE_AUTH_EMULATOR_HOST=firebase-emulators:9099
FIREBASE_DATABASE_EMULATOR_HOST=firebase-emulators:9000
FIREBASE_PUBSUB_EMULATOR_HOST=firebase-emulators:8085
FIREBASE_STORAGE_EMULATOR_HOST=firebase-emulators:9199
FIRESTORE_EMULATOR_HOST=firebase-emulators:8090
VAULT_ADDR=http://vault-dev:8200
VAULT_DEV_LISTEN_ADDRESS=http://vault-dev:8200
VAULT_DEV_ROOT_TOKEN_ID=root
#----------------------------------------------------------------|
#________________________________________________________________|
EOF

# Set this file according to the local development environment. The file is gitignored due to the local nature of the configuration.
# The file is created in the current working directory or the specified WORKING_DIR environment variable.
dockerComposeOverride=${WORKING_DIR:-${PWD}}/.docker-compose-services-override.yml
[ -f $dockerComposeOverride ] || cat <<'EOF' > $dockerComposeOverride
services:
  dev:
    image: ${LOCAL_BUILDER_IMAGE:-europe-west1-docker.pkg.dev/${GOOGLE_CLOUD_PROJECT_ID}/docker-repository-public/vegito-local:builder-${LOCAL_VERSION}}
    environment:
      # Enable or disable the use of the local development environment.
      - MAKE_DEV_ON_START=${MAKE_DEV_ON_START:-false}
      # Enable or disable the use of the local test environment.
      - MAKE_TESTS_ON_START=${MAKE_TESTS_ON_START:-false}
      # Enable or disable the use of the local container installation.
      - LOCAL_CONTAINER_INSTALL=${LOCAL_CONTAINER_INSTALL:-false}
    command: |
      bash -c '
        make docker-sock
        if [ "$${MAKE_DEV_ON_START}" = "true" ] ; then
          make dev
        fi
        if [ "$${MAKE_TESTS_ON_START}" = "true" ] ; then
          make application-mobile-wait-for-boot
          make functional-tests
        fi
        sleep infinity
      '

  android-studio:
    image: europe-west1-docker.pkg.dev/${GOOGLE_CLOUD_PROJECT_ID}/docker-repository-public/vegito-local:android-studio-${LOCAL_VERSION}
    environment:
      LOCAL_ANDROID_EMULATOR_DATA: ${PWD}/tests/mobile_images
      LOCAL_ANDROID_STUDIO_ON_START: ${LOCAL_ANDROID_STUDIO_ON_START:-false}
      LOCAL_ANDROID_STUDIO_CACHES_REFRESH: ${LOCAL_ANDROID_STUDIO_CACHES_REFRESH:-false}
      LOCAL_ANDROID_STUDIO_CONTAINER_CACHE: ${LOCAL_ANDROID_STUDIO_CONTAINER_CACHE:-${PWD}/.containers/android-studio}
    working_dir: ${PWD}/mobile

  clarinet-devnet:
    image: europe-west1-docker.pkg.dev/${GOOGLE_CLOUD_PROJECT_ID}/docker-repository-public/vegito-local:clarinet-${LOCAL_VERSION}
    environment:
      LOCAL_CLARINET_DEVNET_CACHES_REFRESH: ${LOCAL_CLARINET_DEVNET_CACHES_REFRESH:-false}
      LOCAL_CLARINET_DEVNET_CONTAINER_CACHE: ${LOCAL_CLARINET_DEVNET_CONTAINER_CACHE:-${PWD}/.containers/clarinet-devnet}

  robotframework:
    image: europe-west1-docker.pkg.dev/${GOOGLE_CLOUD_PROJECT_ID}/docker-repository-public/vegito-local:robotframework-${LOCAL_VERSION}
    working_dir: ${PWD}/tests
    environment:
      LOCAL_ROBOTFRAMEWORK_TESTS_DIR: ${PWD}/tests
      LOCAL_ROBOTFRAMEWORK_CONTAINER_CACHE: ${LOCAL_ROBOTFRAMEWORK_CONTAINER_CACHE:-${PWD}/.containers/robotframework}
      LOCAL_ROBOTFRAMEWORK_CACHES_REFRESH: ${LOCAL_ROBOTFRAMEWORK_CACHES_REFRESH:-false}
  
  firebase-emulators:
    image: europe-west1-docker.pkg.dev/${GOOGLE_CLOUD_PROJECT_ID}/docker-repository-public/vegito-local:firebase-emulators-${LOCAL_VERSION}

  vault-dev:
    image: europe-west1-docker.pkg.dev/${GOOGLE_CLOUD_PROJECT_ID}/docker-repository-public/vegito-local:vault-dev-${LOCAL_VERSION}
    working_dir: ${PWD}/
    command: |
      bash -c '
      set -euo pipefail
      ./vault-init.sh
      sleep infinity
      '
EOF


mobileLaunchDebug=${PWD}/tests/robot/.vscode/launch.json
if [ ! -f $mobileLaunchDebug ] ;  then
mkdir -p $(dirname $mobileLaunchDebug)
cat <<'EOF' > $mobileLaunchDebug
{
    "workbench.colorTheme": "Red",
    "robotcode.languageServer.mode": "stdio",
    "robotcode.analysis.progressMode": "detailed",
    "robotcode.workspace.excludePatterns": [
        ".hatch/",
        ".venv/",
        "node_modules/",
        ".pytest_cache/",
        "__pycache__/",
        ".mypy_cache/",
        ".robotcode_cache/"
    ],
    "robotcode.robot.outputDir": "${workspaceFolder}/results",
    "robotcode.analysis.diagnosticMode": "workspace",
    "robotcode.analysis.referencesCodeLens": false,
}
EOF
fi

dockerNetworkName=${VEGITO_LOCAL_DOCKER_NETWORK_NAME:-dev}
dockerComposeNetworksOverride=${WORKING_DIR:-${PWD}}/.docker-compose-networks-override.yml
[ -f $dockerComposeNetworksOverride ] || cat <<EOF > $dockerComposeNetworksOverride
networks:
  ${dockerNetworkName}:
    driver: bridge

services:
  dev:
    networks:
      ${dockerNetworkName}:
        aliases:
          - devcontainer
    ports:
      # Docker daemon
      - 2375

  example-application-backend:
    networks:
      ${dockerNetworkName}:
        aliases:
          - example-application-backend
    ports:
      # HTTP
      - 8080

  example-application-mobile:
    networks:
      ${dockerNetworkName}:
        aliases:
          - example-application-mobile
    ports:
      # VNC
      # - 5900
      # Xpra
      - 5901
      # ADB
      # - 5037

  example-application-tests:
    networks:
      dev:
        aliases:
          - example-application-tests

  firebase-emulators:
    networks:
      ${dockerNetworkName}:
        aliases:
          - firebase-emulators
    ports:
      # UI
      - 4000
      # Hub
      # - 4400
      # Firebase Reserved
      # - 4500
      # Functions
      # - 5001
      # Pub/Sub
      # - 8085
      # Firestore
      # - 8090
      # Database
      # - 9000
      # Login CLI
      # - 9005
      # Auth
      # - 9099
      # Firebase Reserved
      # - 9150
      # Storage
      # - 9199
      # Firebase Triggers
      # - 9299

  clarinet-devnet:
    networks:
      ${dockerNetworkName}:
        aliases:
          - clarinet-devnet
    ports:
      # Docker daemon
      - 2375

  android-studio:
    networks:
      ${dockerNetworkName}:
        aliases:
          - android-studio
    ports:
      # VNC
      # - 5900
      # Xpra
      - 5901
      # ADB
      # - 5037
      # Flutter Tools
      - 9100
  vault-dev:
    networks:
      ${dockerNetworkName}:
        aliases:
          - vault-dev
    ports:
      # Server HTTP API
      # - 8200
      # UI
      - 8201

  robotframework:
    networks:
      ${dockerNetworkName}:
        aliases:
          - robotframework
    ports:
      # HTTP
      - 8080
EOF

# Set this file according to the local development environment. The file is gitignored due to the local nature of the configuration.
# The file is created in the current working directory or the specified WORKING_DIR environment variable.
dockerComposeGpuOverride=${WORKING_DIR:-${PWD}}/.docker-compose-gpu-override.yml
[ -f $dockerComposeGpuOverride ] || cat <<'EOF' > $dockerComposeGpuOverride
services:
  android-studio:
    # environment:
    #  LOCAL_ANDROID_GPU_MODE=host
    # runtime: nvidia
    # devices:
    #   - /dev/nvidia0
  example-application-mobile:
    # environment:
    #  LOCAL_ANDROID_GPU_MODE: host
    # runtime: nvidia
    # devices:
    #   - /dev/nvidia0
    # shm_size: "8gb"
    # group_add:
    #   - sgx
EOF

