#!/bin/sh

set -eu

trap "echo Exited with code $?." EXIT

# Android Cache
ANDROID_CACHE=${HOME}/.android
rm -rf $ANDROID_CACHE
mkdir -p ${PWD}/local/android/studio/cache
ln -sf ${PWD}/local/android/studio/cache $ANDROID_CACHE

export DISPLAY=":1"

# Lancez xvfb en arrière-plan
LGUltraFine5KRes=2560x1440 # LG UltraFine
LGUltraFine5KRes_b=2148x1152 # LG UltraFine
MacBookAirRes=1440x900

Xvfb ${DISPLAY} -nolisten tcp -cc 4 -screen 0, ${MacBookAirRes}x24 &

# Boucle d'attente pour permettre à xvfb de démarrer
while ! xdpyinfo -display ${DISPLAY} > /dev/null 2>&1; do sleep 1; done

x11vnc -display ${DISPLAY} -nopw -forever &

openbox&

exec $@
