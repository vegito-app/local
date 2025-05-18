#!/bin/bash

set -x

trap "echo Exited with code $?." EXIT

# display-start.sh

# studio-caches-refresh.sh 

# xset r on

# List to hold background job PIDs
bg_pids=()

# Function to kill background jobs when script ends
kill_jobs() {
    echo "Killing background jobs"
    for pid in "$${bg_pids[@]}"; do
        kill "$$pid"
        wait "$$pid" 2>/dev/null
    done
}

# Trap to call kill_jobs on script exit
trap kill_jobs EXIT

# Forward firebase-emulators to container as localhost
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
socat TCP-LISTEN:8090,fork,reuseaddr TCP:firebase-emulators:8090 > /tmp/socat-firebase-emulators-8090.log 2>&1 &
bg_pids+=("$!")
socat TCP-LISTEN:5001,fork,reuseaddr TCP:firebase-emulators:5001 > /tmp/socat-firebase-emulators-5001.log 2>&1 &
bg_pids+=("$!")
socat TCP-LISTEN:4000,fork,reuseaddr TCP:firebase-emulators:4000 > /tmp/socat-firebase-emulators-4000.log 2>&1 &
bg_pids+=("$!")

# access to backend using localhost (position retrieval unauthorized using insecure http frontend with google-chrome)
socat TCP-LISTEN:8080,fork,reuseaddr TCP:application-backend:8080 > /tmp/socat-backend-8080.log 2>&1 &
bg_pids+=("$!")

# access to backend launched with debugger in container dev using localhost (position retrieval unauthorized using insecure http frontend with google-chrome)
socat TCP-LISTEN:8081,fork,reuseaddr TCP:dev:8080 > /tmp/socat-dev-8080.log 2>&1 &
bg_pids+=("$!")

exec "$@"
