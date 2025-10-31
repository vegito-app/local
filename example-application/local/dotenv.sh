#!/bin/bash

# This script is run on the host as devcontainer 'initializeCommand' 
# (cf. https://containers.dev/implementors/json_reference/#lifecycle-scripts)

set -euo pipefail

trap "echo Exited with code $?." EXIT

projectName=${VEGITO_PROJECT_NAME:-vegito-local}
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
# Enable or disable the use of the Docker registry cache.
# Enable or disable the use of the local development environment.
MAKE_DEV_ON_START=${MAKE_DEV_ON_START:-true}
# Make sure to set the correct values for using your personnal credentials IAM permissions. 
VEGITO_PROJECT_USER=${VEGITO_PROJECT_USER:-${USER:-vegito-developer-id}}
# 
GOOGLE_CLOUD_PROJECT_ID=${DEV_GOOGLE_CLOUD_PROJECT_ID}
#------------------------------------------------------- 
# The following resources are used for the local development environment:
# 
DEV_GOOGLE_IDP_OAUTH_KEY_SECRET_ID=projects/${DEV_GOOGLE_CLOUD_PROJECT_ID}/secrets/google-idp-oauth-key/versions/latest
DEV_GOOGLE_IDP_OAUTH_CLIENT_ID_SECRET_ID=projects/${DEV_GOOGLE_CLOUD_PROJECT_ID}/secrets/google-idp-oauth-client-id/versions/latest
DEV_STRIPE_KEY_SECRET_SECRET_ID=projects/${DEV_GOOGLE_CLOUD_PROJECT_ID}/secrets/stripe-key/versions/latest
# 
LOCAL_BUILDER_IMAGE=europe-west1-docker.pkg.dev/${GOOGLE_CLOUD_PROJECT_ID}/docker-repository-public/vegito-local:builder-${VERSION:-latest}
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
    image: europe-west1-docker.pkg.dev/${GOOGLE_CLOUD_PROJECT_ID}/docker-repository-public/vegito-local:builder-latest
    environment:
      - LOCAL_BUILDER_IMAGE=europe-west1-docker.pkg.dev/${GOOGLE_CLOUD_PROJECT_ID}/docker-repository-public/vegito-local:builder-latest
      - MAKE_DEV_ON_START=true
      - LOCAL_APPLICATION_TESTS_RUN_ON_START=true
      - LOCAL_CONTAINER_INSTALL=1
    command: |
      bash -c '
        make docker-sock
        if [ "${MAKE_DEV_ON_START:-true}" = "true" ] ; then
          make dev
        fi
        if [ "${MAKE_TESTS_ON_START:-false}" = "true" ] ; then
          make application-mobile-wait-for-boot
          make functional-tests
        fi
        sleep infinity
      '
  example-application-mobile:
    working_dir: ${PWD}/example-application/mobile
    environment:
      LOCAL_ANDROID_EMULATOR_DATA: ${PWD}/example-application/tests/mobile_images

  example-application-tests:
    working_dir: ${PWD}/example-application/tests
    environment:
      LOCAL_ROBOTFRAMEWORK_TESTS_DIR: ${PWD}/example-application/tests

  android-studio:
    image: europe-west1-docker.pkg.dev/${GOOGLE_CLOUD_PROJECT_ID}/docker-repository-public/vegito-local:android-studio-latest
    environment:
      LOCAL_ANDROID_EMULATOR_DATA: ${PWD}/example-application/tests/mobile_images
      LOCAL_ANDROID_STUDIO_ON_START: false
      LOCAL_ANDROID_STUDIO_CACHES_REFRESH: true
    working_dir: ${PWD}/example-application/mobile
  clarinet-devnet:
    image: europe-west1-docker.pkg.dev/${GOOGLE_CLOUD_PROJECT_ID}/docker-repository-public/vegito-local:clarinet-latest
    environment:
      LOCAL_CLARINET_DEVNET_CACHES_REFRESH: ${LOCAL_CLARINET_DEVNET_CACHES_REFRESH:-true}
      
  robotframework:
    working_dir: ${PWD}/example-application/tests
    environment:
      LOCAL_ROBOTFRAMEWORK_TESTS_DIR: ${PWD}/example-application/tests

  firebase-emulators:
    image: europe-west1-docker.pkg.dev/${GOOGLE_CLOUD_PROJECT_ID}/docker-repository-public/vegito-local:firebase-emulators-latest
    environment:
      LOCAL_FIREBASE_EMULATORS_PUBSUB_VEGETABLE_IMAGES_VALIDATED_BACKEND_SUBSCRIPTION=vegetable-images-validated-backend
      LOCAL_FIREBASE_EMULATORS_PUBSUB_VEGETABLE_IMAGES_VALIDATED_BACKEND_SUBSCRIPTION_DEBUG=vegetable-images-validated-backend-debug
      LOCAL_FIREBASE_EMULATORS_PUBSUB_VEGETABLE_IMAGES_CREATED_TOPIC=vegetable-images-created

  vault-dev:
    image: europe-west1-docker.pkg.dev/${GOOGLE_CLOUD_PROJECT_ID}/docker-repository-public/vegito-local:vault-dev-latest
    working_dir: ${PWD}/example-application/
    command: |
      bash -c '
      set -euo pipefail
      ./vault-init.sh
      sleep infinity
      '
EOF

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

  example-application-backend:
    networks:
      ${dockerNetworkName}:
        aliases:
          - example-application-backend

  example-application-mobile:
    networks:
      ${dockerNetworkName}:
        aliases:
          - example-application-mobile

  example-application-tests:
    networks:
      ${dockerNetworkName}:
        aliases:
          - example-application-tests

  firebase-emulators:
    networks:
      ${dockerNetworkName}:
        aliases:
          - firebase-emulators

  clarinet-devnet:
    networks:
      ${dockerNetworkName}:
        aliases:
          - clarinet-devnet

  android-studio:
    networks:
      ${dockerNetworkName}:
        aliases:
          - android-studio

  android-appium:
    networks:
      ${dockerNetworkName}:
        aliases:
          - android-appium

  vault-dev:
    networks:
      ${dockerNetworkName}:
        aliases:
          - vault-dev

  robotframework:
    networks:
      ${dockerNetworkName}:
        aliases:
          - robotframework
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

