#!/bin/bash

# This script is run on the host as devcontainer 'initializeCommand' 
# (cf. https://containers.dev/implementors/json_reference/#lifecycle-scripts)

set -eu

trap "echo Exited with code $?." EXIT

# Create default local .env file with minimum required values to start.
localDotenvFile=${LOCAL_DIR}/.env
[ -f $localDotenvFile ] || cat <<EOF > $localDotenvFile
######################################################################## 
# After setting up values in this file, rebuild the local containers.  #
########################################################################
#  
#------------------------------------------------------- 
# Please set the values in this section according to your personnal settings.
# 
# Trigger the local project display name in Docker Compose.
COMPOSE_PROJECT_NAME=${VEGITO_COMPOSE_PROJECT_NAME:-vegito-dev-${VEGITO_PROJECT_USER:-local-user}}
# 
# Make sure to set the correct values for using your personnal credentials IAM permissions. 
VEGITO_PROJECT_USER=${VEGITO_PROJECT_USER:-local-user}
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
LOCAL_ANDROID_STUDIO_APK_PATH=application/mobile/build/app/outputs/flutter-apk/app-release.apk
#
# Wether to currently run the local application tests on start.
# If set to 'true', the local application tests will be run on start.
MAKE_LOCAL_APPLICATION_TESTS_RUN_ON_START=true
# 
#------------------------------------------------------- 
# The following variables are used with the local development environment.
# 
GOOGLE_CLOUD_PROJECT_ID=${DEV_GOOGLE_CLOUD_PROJECT_ID}
DEV_GOOGLE_IDP_OAUTH_KEY_SECRET_ID=projects/${DEV_GOOGLE_CLOUD_PROJECT_ID}/secrets/google-idp-oauth-key/versions/latest
DEV_GOOGLE_IDP_OAUTH_CLIENT_ID_SECRET_ID=projects/${DEV_GOOGLE_CLOUD_PROJECT_ID}/secrets/google-idp-oauth-client-id/versions/latest
DEV_STRIPE_KEY_SECRET_SECRET_ID=projects/${DEV_GOOGLE_CLOUD_PROJECT_ID}/secrets/stripe-key/versions/latest
# 
BUILDER_IMAGE=europe-west1-docker.pkg.dev/${DEV_GOOGLE_CLOUD_PROJECT_ID}/docker-repository-public/${DEV_GOOGLE_CLOUD_PROJECT_ID}:builder-latest
FIREBASE_ADMINSDK_SERVICEACCOUNT_ID=projects/${DEV_GOOGLE_CLOUD_PROJECT_ID}/secrets/firebase-adminsdk-service-account-key/versions/latest
FIREBASE_PROJECT_ID=${DEV_GOOGLE_CLOUD_PROJECT_ID}

LOCAL_FIREBASE_EMULATORS_PUBSUB_VEGETABLE_IMAGES_VALIDATED_BACKEND_SUBSCRIPTION=vegetable-images-validated-backend
LOCAL_FIREBASE_EMULATORS_PUBSUB_VEGETABLE_IMAGES_CREATED_TOPIC=vegetable-images-created

# Set this value tu 'host' to use accelerated GPU rendering in Android Studio.
# Set to 'swiftshader_indirect' to use software rendering if you are not using a GPU.
LOCAL_ANDROID_STUDIO_ANDROID_GPU_MODE=swiftshader_indirect

# Set this value to 'Pixel_8_Intel' or 'Pixel_6_Playstore' to use the corresponding AVD.
LOCAL_ANDROID_STUDIO_ANDROID_AVD_NAME=Pixel_6_Playstore

UI_CONFIG_FIREBASE_SECRET_ID=projects/${DEV_GOOGLE_CLOUD_PROJECT_ID}/secrets/firebase-config-web/versions/latest
UI_CONFIG_GOOGLEMAPS_SECRET_ID=projects/${DEV_GOOGLE_CLOUD_PROJECT_ID}/secrets/${VEGITO_PROJECT_USER}-googlemaps-web-api-key/versions/latest

FIREBASE_STORAGE_PUBLIC_PREFIX=https://firebasestorage.googleapis.com/v0/b/${DEV_GOOGLE_CLOUD_PROJECT_ID}.appspot.com/o
CDN_PUBLIC_PREFIX=https://cdn.mon-backend.com  # ton CDN public GCS
# 
#--------------------------------------------------------
# ! Should not configure this section !
#
# The following variables are used for propagating the containers
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
STRIPE_KEY_PUBLISHABLE_SECRET_ID=projects/${DEV_GOOGLE_CLOUD_PROJECT_ID}/secrets/stripe-key/versions/latest
STRIPE_KEY_SECRET_SECRET_ID=projects/${DEV_GOOGLE_CLOUD_PROJECT_ID}/secrets/stripe-key/versions/latest
# 
# ! Should not configure this section !
#---------------------------------------------------------
EOF

# Set this file according to the local development environment. The file is gitignored due to the local nature of the configuration.
# The file is created in the current working directory or the specified WORKING_DIR environment variable.
dockerComposeOverride=${WORKING_DIR:-${PWD}}/.docker-compose-override.yml
[ -f $dockerComposeOverride ] || cat <<'EOF' > $dockerComposeOverride
services:
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
      sleep infinity
      '
      # "ndk;${android_ndk_version}" \
  android-studio:
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
    working_dir: ${PWD}/clarinet-devnet
    command: |
      bash -c '
      set -eu
      make -C ../.. local-clarinet-devnet-start
      sleep infinity
      '
  application-tests:
    working_dir: ${PWD}/tests

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

  firebase-emulators:
    networks:
      ${dockerNetworkName}:

  clarinet-devnet:
    networks:
      ${dockerNetworkName}:

  android-studio:
    networks:
      ${dockerNetworkName}:

  vault-dev:
    networks:
      ${dockerNetworkName}:

  application-tests:
    networks:
      ${dockerNetworkName}:
EOF

# Set this file according to the local development environment. The file is gitignored due to the local nature of the configuration.
# The file is created in the current working directory or the specified WORKING_DIR environment variable.
dockerComposeGpuOverride=${WORKING_DIR:-${PWD}}/.docker-compose-gpu-override.yml
[ -f $dockerComposeGpuOverride ] || cat <<'EOF' > $dockerComposeGpuOverride
services:
  android-studio:
    environment:
      LOCAL_ANDROID_GPU_MODE: ${LOCAL_ANDROID_STUDIO_ANDROID_GPU_MODE:-host}
    devices:
      - /dev/nvidia0
    # runtime: nvidia # Uncomment this line if you are using the nvidia runtime.
    runtime: runc
    shm_size: "8gb"
    group_add:
      - sgx 
EOF
