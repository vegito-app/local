#!/bin/bash

# This script is used to generate a Docker Compose 
# override file for hardware-specific configurations

set -euo pipefail

currentWorkingDir=${1:-${PWD}}
hardwareDir="${currentWorkingDir}/hardware"

# Set this file according to the local development environment. The file is gitignored due to the local nature of the configuration.
# The file is created in the current working directory or the specified WORKING_DIR environment variable.
hardwareOverride="${currentWorkingDir}/.docker-compose-hardware-override.yml"

hardwareProfile="${VEGITO_DOCKER_HARDWARE_PROFILE:-auto}"

if [ "$hardwareProfile" = "auto" ]; then
    echo "🔍 Detecting Docker hardware capabilities..."

    # This checks the Docker Engine targeted by the Docker CLI.
    dockerRuntimes="$(docker info --format '{{json .Runtimes}}' 2>/dev/null || true)"

    hasNvidia=false
    hasKvm=false
    hasDri=false

    if grep -q '"nvidia"' <<< "$dockerRuntimes"; then
        hasNvidia=true
    fi

    if [ -e /dev/kvm ]; then
        hasKvm=true
    fi

    if [ -e /dev/dri ]; then
        hasDri=true
    fi

    if [ "$hasNvidia" = true ] &&
       [ "$hasKvm" = true ] &&
       [ "$hasDri" = true ]; then

        hardwareProfile="kvm-gpu-nvidia"

    elif [ "$hasKvm" = true ]; then

        hardwareProfile="kvm"

    else

        hardwareProfile="generic"

    fi
fi

echo "🔧 Selected hardware profile: ${hardwareProfile}"

hardwareProfileFile="${hardwareDir}/${hardwareProfile}.yml"

if [ ! -f "$hardwareProfileFile" ]; then
    echo "❌ Hardware profile not found: ${hardwareProfileFile}" >&2
    exit 1
fi

# Preserve a manually maintained regular override.
if [ -e "$hardwareOverride" ] && [ ! -L "$hardwareOverride" ]; then

    echo "⚠️ Existing hardware override is a regular file:"
    echo "   $hardwareOverride"
    echo "   Move it aside before enabling profile symlinks."

    exit 1
fi

# Create or update the relative symbolic link.
ln -sfn \
    "hardware/${hardwareProfile}.yml" \
    "$hardwareOverride"

echo "🔗 Hardware override:"
echo "   ${hardwareOverride} -> hardware/${hardwareProfile}.yml"