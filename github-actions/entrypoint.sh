#!/bin/bash

set -euo pipefail

# Detect if running in Codespaces
if [[ -n "${CODESPACES:-}" ]]; then
  echo "🚀 Running inside Codespaces environment"
  export VEGITO_DOCKER_BUILDX_NAME="${VEGITO_DOCKER_BUILDX_NAME:-vegito-codespaces-builder}"
  # Use a fixed builder name in Codespaces, no per-hostname builder
else
  # Define a unique name for the local Buildx builder
  export HOSTNAME=$(hostname)
  export VEGITO_DOCKER_BUILDX_NAME="${VEGITO_DOCKER_BUILDX_NAME:-vegito-local-gha-builder-${HOSTNAME}}"
fi

export RUNNER_ALLOW_RUNASROOT=false
export RUNNER_ALLOWMULTIPLEJOBS=false

# Cleanup function to deregister the runner and remove the builder
cleanup() {
  echo "🧹 Received signal, cleaning up..."

  echo "🧹 Removing GitHub Actions Runner configuration"
  ./config.sh remove --token "$GITHUB_ACTIONS_RUNNER_TOKEN" || true
  echo "🧹 Removing runner work directory"
  rm -rf /runner/_work/${HOSTNAME:-default}
  
  exit 0
}

# Trap signals for cleanup
trap cleanup SIGHUP SIGINT SIGTERM

WORKSPACE=/runner/_work/${HOSTNAME:-default}
sudo mkdir -p "$WORKSPACE"

# Fix permissions on the working directory
echo 🔧 Fixing ownership of /runner/_work
sudo chown -R github:github /runner/_work || true

# Configure GitHub Actions Runner
cd /runner
./config.sh \
    --url "$GITHUB_ACTIONS_RUNNER_URL" \
    --token "$GITHUB_ACTIONS_RUNNER_TOKEN" \
    --unattended \
    --name "$GITHUB_ACTIONS_RUNNER_STACK-${HOSTNAME:-default}" \
    --work "$WORKSPACE"

# Export the local Buildx builder name as an environment variable for GitHub Actions
{
  echo VEGITO_DOCKER_BUILDX_NAME=$VEGITO_DOCKER_BUILDX_NAME
  echo LOCAL_DOCKER_BUILDX_LOCAL_CACHE_DIR=$WORKSPACE/.containers/docker-buildx-cache
  echo BUILDX_BAKE_ENTITLEMENTS_FS=0
} > "$WORKSPACE/gha-env-vars"

LOCAL_GITHUB_ACTIONS_RUNNER_BUILD_CACHE=${LOCAL_GITHUB_ACTIONS_RUNNER_BUILD_CACHE:-$WORKSPACE/.containers}

# Create symlink for container build cache
mkdir -p "$LOCAL_GITHUB_ACTIONS_RUNNER_BUILD_CACHE"
if [[ "$LOCAL_GITHUB_ACTIONS_RUNNER_BUILD_CACHE" != "$WORKSPACE/.containers" ]]; then
  echo 🔗 Linking Buildx cache directory to runner workspace
  ln -sf "$LOCAL_GITHUB_ACTIONS_RUNNER_BUILD_CACHE" "$WORKSPACE/.containers"
fi

# Launch the runner
echo 🚀 Starting GitHub Actions Runner
./run.sh &

# Wait for process to finish
wait $!