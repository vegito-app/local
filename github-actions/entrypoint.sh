#!/bin/bash

set -euxo pipefail

# Define a unique name for the local Buildx builder
export HOSTNAME=$(hostname)
export LOCAL_DOCKER_BUILDX_NAME="vegito-local-gha-builder-${HOSTNAME}"
export RUNNER_ALLOW_RUNASROOT=false
export RUNNER_ALLOWMULTIPLEJOBS=false

# Cleanup function to deregister the runner and remove the builder
cleanup() {
  echo "🧹 Received signal, cleaning up..."

  if docker buildx inspect "$LOCAL_DOCKER_BUILDX_NAME" >/dev/null 2>&1; then
    echo "🧹 Removing Docker Buildx builder: $LOCAL_DOCKER_BUILDX_NAME"
    docker buildx rm "$LOCAL_DOCKER_BUILDX_NAME" || true
  fi

  echo "🧹 Removing GitHub Actions Runner configuration"
  ./config.sh remove --token "$GITHUB_ACTIONS_RUNNER_TOKEN"
  
  echo "🧹 Removing runner work directory"
  rm -rf /runner/_work/${HOSTNAME}
  
  exit 0
}

# Trap signals for cleanup
trap cleanup SIGHUP SIGINT SIGTERM

# Create a dedicated Buildx builder if it doesn't exist
if ! docker buildx inspect "$LOCAL_DOCKER_BUILDX_NAME" >/dev/null 2>&1; then
  echo "🔧 Creating local Buildx builder: $LOCAL_DOCKER_BUILDX_NAME"
  docker buildx create --name "$LOCAL_DOCKER_BUILDX_NAME" --driver docker-container --use || true
fi

docker buildx use "$LOCAL_DOCKER_BUILDX_NAME"

# Fix permissions on the working directory
echo "🔧 Fixing ownership of /runner/_work"
sudo chown -R "github:github" /runner/_work || true

# Configure GitHub Actions Runner
cd /runner
./config.sh \
    --url "$GITHUB_ACTIONS_RUNNER_URL" \
    --token "$GITHUB_ACTIONS_RUNNER_TOKEN" \
    --unattended \
    --name "$GITHUB_ACTIONS_RUNNER_STACK-$HOSTNAME" \
    --work "/runner/_work/${HOSTNAME}"

WORKSPACE=/runner/_work/${HOSTNAME}
mkdir -p "$WORKSPACE"

# Export the local Buildx builder name as an environment variable for GitHub Actions
echo "LOCAL_DOCKER_BUILDX_NAME=$LOCAL_DOCKER_BUILDX_NAME" > "$WORKSPACE/gha-env-vars"

# Launch the runner
echo "🚀 Starting GitHub Actions Runner"
./run.sh &

# Wait for process to finish
wait $!