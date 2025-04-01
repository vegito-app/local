#!/bin/bash

set -eu

LOCAL_FIREBASE_EMULATORS=${PWD}/.firebase-emulators
mkdir -p $LOCAL_FIREBASE_EMULATORS

# # Android Studio config
FIREBASE_EMULATORS_CACHE=${HOME}/.cache
mkdir -p $LOCAL_FIREBASE_EMULATORS/.cache
ln -s $LOCAL_FIREBASE_EMULATORS/.cache $FIREBASE_EMULATORS_CACHE
