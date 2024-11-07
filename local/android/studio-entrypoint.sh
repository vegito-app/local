#!/bin/bash

set -eu

trap "echo Exited with code $?." EXIT

display-start.sh

local-android-caches-refresh.sh 

studio &

exec "$@"
