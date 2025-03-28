#!/bin/bash

set -eu

trap "echo Exited with code $?." EXIT

display-start.sh

studio-caches-refresh.sh 

xset r on

studio &

exec "$@"
