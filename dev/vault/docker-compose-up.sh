#!/bin/bash

set -eu

VAULT_CONFIG=${PWD}/dev/.containers/vault/config

mkdir -p ${VAULT_CONFIG}

tee ${VAULT_CONFIG}/vault.hcl <<EOF
ui            = true
cluster_addr  = "http://127.0.0.1:8201"
api_addr      = "https://127.0.0.1:8200"
disable_mlock = true

storage "raft" {
  path    = "${PWD}/.vault"
  node_id = "127.0.0.1"
}

listener "tcp" {
  address         = "0.0.0.0:8200"
  cluster_address = "0.0.0.0:8201"
  tls_disable     = 1
}
EOF

# List to hold background job PIDs
bg_pids=()

# Function to kill background jobs when script ends
kill_jobs() {
    echo "Killing background jobs"
    for pid in "${bg_pids[@]}"; do
        kill "$pid"
        wait "$pid" 2>/dev/null
    done
}

# Trap to call kill_jobs on script exit
trap kill_jobs EXIT

socat TCP-LISTEN:8200,fork,reuseaddr TCP:vault-dev:8200 > /tmp/socat-vault-dev-8200.log 2>&1 &
bg_pids+=("$!")

socat TCP-LISTEN:8201,fork,reuseaddr TCP:vault-dev:8201 > /tmp/socat-vault-dev-8201.log 2>&1 &
bg_pids+=("$!")

docker compose -f dev/docker-compose.yml up vault-dev 2>&1
