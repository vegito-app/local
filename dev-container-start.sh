ù#!/bin/bash

set -euo pipefail

# 🚀 Setup background services

# Forwarding host docker socket
socat TCP-LISTEN:23755,fork UNIX-CONNECT:/var/run/docker.sock > /tmp/socat-docker-23755.log 2>&1 &
bg_pids+=("$!")

# Pay attention to use a path that is mounted inside the container. Because you want to edit files from your host machine.
# This is typically a workspace folder mounted inside the container.
# By default, we are using the current working directory (PWD) as the workspace folder.
# You can override the default location by setting the LOCAL_WORKSPACE environment variable.
# Example: export LOCAL_WORKSPACE=/path/to/your/local/workspace
current_workspace=$PWD

LOCAL_WORKSPACE=${LOCAL_WORKSPACE:-/workspaces/vegito-app/local}
if [ "$current_workspace" != "$LOCAL_WORKSPACE" ] ; then
    sudo ln -s $current_workspace $LOCAL_WORKSPACE 2>&1 || true
    echo "Linked current workspace $current_workspace to $LOCAL_WORKSPACE"
fi

# access to backend using localhost (position retrieval unauthorized using insecure http frontend with google-chrome)
socat TCP-LISTEN:8080,fork,reuseaddr TCP:application-backend:8080 > /tmp/socat-backend-8080.log 2>&1 &
bg_pids+=("$!")

# access to debug backend using localhost (position retrieval unauthorized using insecure http frontend with google-chrome)
socat TCP-LISTEN:8888,fork,reuseaddr TCP:devcontainer:8888 > /tmp/socat-devcontainer-8888.log 2>&1 &
bg_pids+=("$!")

if [ -f /usr/local/bin/desktop-x-start.sh ]; then

    echo "🖥️ X Desktop starting..."
    /usr/local/bin/desktop-x-start.sh &
    bg_pids+=("$!")

    # Forward firebase-emulators to container as localhost. 
    # Just open chrome on http://localhost:4000 from XPRA session to access it's web interface.
    socat TCP-LISTEN:9299,fork,reuseaddr TCP:firebase-emulators:9399 > /tmp/socat-firebase-emulators-9399.log 2>&1 &
    bg_pids+=("$!")
    socat TCP-LISTEN:4500,fork,reuseaddr TCP:firebase-emulators:4501 > /tmp/socat-firebase-emulators-4501.log 2>&1 &
    bg_pids+=("$!")
    socat TCP-LISTEN:4400,fork,reuseaddr TCP:firebase-emulators:4401 > /tmp/socat-firebase-emulators-4401.log 2>&1 &
    bg_pids+=("$!")
    socat TCP-LISTEN:9000,fork,reuseaddr TCP:firebase-emulators:9000 > /tmp/socat-firebase-emulators-9000.log 2>&1 &
    bg_pids+=("$!")
    socat TCP-LISTEN:9099,fork,reuseaddr TCP:firebase-emulators:9099 > /tmp/socat-firebase-emulators-9099.log 2>&1 &
    bg_pids+=("$!")
    socat TCP-LISTEN:9150,fork,reuseaddr TCP:firebase-emulators:9150 > /tmp/socat-firebase-emulators-9150.log 2>&1 &
    bg_pids+=("$!")
    socat TCP-LISTEN:9199,fork,reuseaddr TCP:firebase-emulators:9199 > /tmp/socat-firebase-emulators-9199.log 2>&1 &
    bg_pids+=("$!")
    socat TCP-LISTEN:8085,fork,reuseaddr TCP:firebase-emulators:8085 > /tmp/socat-firebase-emulators-8085.log 2>&1 &
    bg_pids+=("$!")
    socat TCP-LISTEN:8090,fork,reuseaddr TCP:firebase-emulators:8090 > /tmp/socat-firebase-emulators-8090.log 2>&1 &
    bg_pids+=("$!")
    socat TCP-LISTEN:5001,fork,reuseaddr TCP:firebase-emulators:5001 > /tmp/socat-firebase-emulators-5001.log 2>&1 &
    bg_pids+=("$!")
    socat TCP-LISTEN:4000,fork,reuseaddr TCP:firebase-emulators:4000 > /tmp/socat-firebase-emulators-4000.log 2>&1 &
    bg_pids+=("$!")

else
    echo "🖥️ X Desktop not started."
fi

if [ -f /usr/local/bin/debian-dind-rootless-start.sh ]; then

    echo "🐳 Starting Docker DIND Rootless"
    /usr/local/bin/debian-dind-rootless-start.sh &
    bg_pids+=("$!")

    # Forward Docker DIND Rootless socket
    socat TCP-LISTEN:23766,fork UNIX-CONNECT:/run/user/1000/docker/docker.sock > /tmp/socat-docker-23766.log 2>&1 &
    bg_pids+=("$!")

else
    echo "🐳 Docker DIND Rootless not started."
fi

echo " 🚀 Starting local runtime"
project-container-start.sh &
bg_pids+=("$!")

sleep infinity