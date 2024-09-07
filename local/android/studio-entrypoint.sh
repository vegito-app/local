#!/bin/bash

set -eu

trap "echo Exited with code $?." EXIT

# Android Cache
ANDROID_CACHE=${HOME}/.android
rm -rf $ANDROID_CACHE
mkdir -p ${PWD}/local/android/studio/cache
ln -sf ${PWD}/local/android/studio/cache $ANDROID_CACHE

export DISPLAY=":1"

display-start.sh

exec "$@"
