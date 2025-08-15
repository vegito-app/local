#!/bin/bash

# This script is run on the host as devcontainer 'initializeCommand' 
# (cf. https://containers.dev/implementors/json_reference/#lifecycle-scripts)

set -eu

trap "echo Exited with code $?." EXIT

projectName=${VEGITO_PROJECT_NAME:-vegito-local}
projectUser=${VEGITO_PROJECT_USER:-local-developer-id}
localDockerComposeProjectName=${VEGITO_COMPOSE_PROJECT_NAME:-$projectName-$projectUser}

currentWorkingDir=${WORKING_DIR:-${PWD}}
# Ensure the current working directory exists.
# Create default local .env file with minimum required values to start.
localDotenvFile=${currentWorkingDir}/.env

[ -f ${localDotenvFile} ] || cat <<EOF > ${localDotenvFile}
######################################################################## 
# After setting up values in this file, rebuild the local containers.  #
########################################################################
#  
# Please set the values in this section according to your personnal values.
#------------------------------------------------------- 
# Please set the values in this section according to your personnal settings.
# 
# Trigger the local project display name in Docker Compose.
COMPOSE_PROJECT_NAME=${localDockerComposeProjectName}
# 
# Make sure to set the correct values for using your personnal credentials IAM permissions. 
VEGITO_PROJECT_USER=${VEGITO_PROJECT_USER:-local-developer-id}
# 
# Trigger the local project display name in Docker Compose.
COMPOSE_PROJECT_NAME=${VEGITO_COMPOSE_PROJECT_NAME:-vegito-repo-${VEGITO_PROJECT_USER:-${USER:-vegito-developer-id}}}
# 
#------------------------------------------------------- 
# The following resources are used for the local development environment:
#
DEV_GOOGLE_IDP_OAUTH_KEY_SECRET_ID=projects/${DEV_GOOGLE_CLOUD_PROJECT_ID}/secrets/google-idp-oauth-key/versions/latest
DEV_GOOGLE_IDP_OAUTH_CLIENT_ID_SECRET_ID=projects/${DEV_GOOGLE_CLOUD_PROJECT_ID}/secrets/google-idp-oauth-client-id/versions/latest
DEV_STRIPE_KEY_SECRET_SECRET_ID=projects/${DEV_GOOGLE_CLOUD_PROJECT_ID}/secrets/stripe-key/versions/latest
# 
LOCAL_BUILDER_IMAGE=europe-west1-docker.pkg.dev/${DEV_GOOGLE_CLOUD_PROJECT_ID}/docker-repository-public/${projectName}:builder-latest
#
FIREBASE_ADMINSDK_SERVICEACCOUNT_ID=projects/${DEV_GOOGLE_CLOUD_PROJECT_ID}/secrets/firebase-adminsdk-service-account-key/versions/latest
FIREBASE_PROJECT_ID=${DEV_GOOGLE_CLOUD_PROJECT_ID}
# 
UI_CONFIG_FIREBASE_SECRET_ID=projects/${DEV_GOOGLE_CLOUD_PROJECT_ID}/secrets/firebase-config-web/versions/latest
UI_CONFIG_GOOGLEMAPS_SECRET_ID=projects/${DEV_GOOGLE_CLOUD_PROJECT_ID}/secrets/david-berichon-googlemaps-web-api-key/versions/latest
# 
FIREBASE_STORAGE_PUBLIC_PREFIX=https://firebasestorage.googleapis.com/v0/b/${DEV_GOOGLE_CLOUD_PROJECT_ID}.appspot.com/o
CDN_PUBLIC_PREFIX=https://cdn.mon-backend.com  # ton CDN public GCS
# 
STRIPE_KEY_PUBLISHABLE_SECRET_ID=projects/${DEV_GOOGLE_CLOUD_PROJECT_ID}/secrets/stripe-key/versions/latest
STRIPE_KEY_SECRET_SECRET_ID=projects/${DEV_GOOGLE_CLOUD_PROJECT_ID}/secrets/stripe-key/versions/latest
# 
GITHUB_ACTIONS_RUNNER_URL=https://github.com/vegito-app
#----------------------------------------------------------------|
#----------------------------------------------------------------|
# The following variables are used for propagating the containers|
# configurations between them each others selves.
#                                                                
ANDROID_HOST=android-studio
APPLICATION_BACKEND_URL=http://application-backend:8080
APPLICATION_BACKEND_DEBUG_URL=http://application-backend:8888
CLARINET_RPC=http://clarinet-devnet:20443
FIREBASE_AUTH_EMULATOR_HOST=firebase-emulators:9099
FIREBASE_DATABASE_EMULATOR_HOST=firebase-emulators:9000
FIREBASE_STORAGE_EMULATOR_HOST=firebase-emulators:9199
FIREBASE_PUBSUB_EMULATOR_HOST=firebase-emulators:8085
FIRESTORE_EMULATOR_HOST=firebase-emulators:8090
VAULT_ADDR=http://vault-dev:8200
VAULT_DEV_ROOT_TOKEN_ID=root
VAULT_DEV_LISTEN_ADDRESS=http://vault-dev:8200
#----------------------------------------------------------------|
#________________________________________________________________|
EOF

# Set this file according to the local development environment. The file is gitignored due to the local nature of the configuration.
# The file is created in the current working directory or the specified WORKING_DIR environment variable.
dockerComposeOverride=${WORKING_DIR:-${PWD}}/.docker-compose-override.yml
[ -f $dockerComposeOverride ] || cat <<'EOF' > $dockerComposeOverride
services:
  application-backend:
    environment:
      GOOGLE_APPLICATION_CREDENTIALS=${GOOGLE_APPLICATION_CREDENTIALS:-/${PWD}/infra/dev/google_application_credentials.json}
      LOCAL_BUILDER_IMAGE=europe-west1-docker.pkg.dev/${DEV_GOOGLE_CLOUD_PROJECT_ID}/docker-repository-public/${DEV_GOOGLE_CLOUD_PROJECT_ID}:builder-latest
      MAKE_DEV_ON_START=true
      LOCAL_APPLICATION_TESTS_RUN_ON_START=true

  dev:
    image: europe-west1-docker.pkg.dev/${GOOGLE_CLOUD_PROJECT_ID:-moov-dev-439608}/docker-repository-public/vegito-app:builder-latest
    command: |
      bash -c '
        make docker-sock
        if [ "$${MAKE_DEV_ON_START}" = "true" ] ; then
          make dev
        fi
        if [ "$${LOCAL_APPLICATION_TESTS_RUN_ON_START}" = "true" ] ; then
          until make local-application-tests-check-env ; do
            echo "[application-tests] Waiting for environment to be ready..."
            sleep 5
          done
          make application-tests
        fi
        sudo chsh -s /usr/bin/zsh root
        sudo chsh -s /usr/bin/zsh vegito
        sleep infinity
      '
  android-studio:
    environment:
      - LOCAL_APPLICATION_TESTS_MOBILE_IMAGES_DIR=${PWD}/application/tests/mobile_images
      - LOCAL_ANDROID_STUDIO_ON_START=true
      - LOCAL_ANDROID_STUDIO_ENV_SETUP=true
      - LOCAL_ANDROID_STUDIO_APPIUM_EMULATOR_AVD_ON_START=true
      - LOCAL_ANDROID_STUDIO_APK_PATH=mobile/build/app/outputs/flutter-apk/app-release.apk
      - LOCAL_ANDROID_STUDIO_ANDROID_AVD_NAME=Pixel_8_Intel

    working_dir: ${PWD}/mobile
    command: |
      bash -c '

      # sdkmanager \
      # "platforms;android-30" \
      # "platforms;android-36" \
      # "sources;android-36" \
      # "build-tools;30.0.1" \
      # "build-tools;35.0.0" \
      # "build-tools;36.0.0" \
      # "system-images;android-34;google_apis;x86_64"

      # sdkmanager --install "system-images;android-33;google_apis;x86_64"

      # echo "no" | avdmanager create avd -n Pixel_8_Intel -k "system-images;android-33;google_apis;x86_64" -d "pixel"
      # echo "no" | avdmanager create avd -n Pixel_6_Playstore -k "system-images;android-34;google_apis_playstore;x86_64" -d "pixel_6"
      # echo "no" | avdmanager create avd -n Pixel_6_ApiOnly -k "system-images;android-34;google_apis;x86_64" -d "pixel_6"
      
      sleep infinity
      '
  vault-dev:
    working_dir: ${PWD}
    
  clarinet-devnet:
    working_dir: ${PWD}/local/clarinet-devnet
    command: |
      bash -c '
      set -eu
      make -C .. local-clarinet-devnet-start
      sleep infinity
      '
  application-tests:
    working_dir: ${PWD}/tests
    environment:
      LOCAL_APPLICATION_TESTS_DIR: ${PWD}/tests

  firebase-emulators:
    environment:
      LOCAL_FIREBASE_EMULATORS_PUBSUB_VEGETABLE_IMAGES_VALIDATED_BACKEND_SUBSCRIPTION=vegetable-images-validated-backend
      LOCAL_FIREBASE_EMULATORS_PUBSUB_VEGETABLE_IMAGES_VALIDATED_BACKEND_SUBSCRIPTION_DEBUG=vegetable-images-validated-backend-debug
      LOCAL_FIREBASE_EMULATORS_PUBSUB_VEGETABLE_IMAGES_CREATED_TOPIC=vegetable-images-created
    command: |
      bash -c '
      set -eu
      
      make local-firebase-emulators-pubsub-init local-firebase-emulators-pubsub-check
      
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

  application-backend:
    networks:
      ${dockerNetworkName}:
        aliases:
          - application-backend

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

  vault-dev:
    networks:
      ${dockerNetworkName}:
        aliases:
          - vault-dev

  application-tests:
    networks:
      ${dockerNetworkName}:
        aliases:
          - application-tests
EOF

# Set this file according to the local development environment. The file is gitignored due to the local nature of the configuration.
# The file is created in the current working directory or the specified WORKING_DIR environment variable.
dockerComposeGpuOverride=${WORKING_DIR:-${PWD}}/.docker-compose-gpu-override.yml
[ -f $dockerComposeGpuOverride ] || cat <<'EOF' > $dockerComposeGpuOverride
services:
  android-studio:
    # environment:
    #   LOCAL_ANDROID_ANDROID_GPU_MODE=host
    # devices:
    #   - /dev/nvidia0
    # # runtime: nvidia # Uncomment this line if you are using the nvidia runtime.
    # runtime: runc
    # shm_size: "8gb"
    # group_add:
    #   - sgx
EOF

