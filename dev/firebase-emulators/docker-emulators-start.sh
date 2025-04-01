#!/bin/bash

set -eux

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

make firebase-emulators-install
make firebase-emulators-start &
bg_pids+=("$!") 

# Need localproxy to forward some required port that could not be 
# configured to listen on 0.0.0.0 from firebase.json file.
TARGET_PORT=4400 LISTEN_PORT=4401 localproxy &
bg_pids+=("$!") 
until nc -z localhost 4500; do
    echo Waiting Firebase Emulator Reserved port at http://localhost:4500/ ;
    sleep 1 ;
done
TARGET_PORT=4500 LISTEN_PORT=4501 localproxy &
bg_pids+=("$!") 
until nc -z localhost 9299; do
    echo Waiting Firebase Emulator Reserved port 3 at http://localhost:9299/ ;
    sleep 1 ;
done
TARGET_PORT=9299 LISTEN_PORT=9399 localproxy &
bg_pids+=("$!") 

while true ; do sleep 1000 ; done