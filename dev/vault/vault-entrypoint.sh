#!/bin/sh

set -eu

trap "echo Exited with code $?." EXIT

mkdir -p ${VAULT_DATA}
mkdir -p ${VAULT_CONFIG}
mkdir -p ${VAULT_AUDIT}

exec "$@"
