#!/usr/bin/env bash
set -x

echo "Devcontainer init started"

make docker-sock || echo "docker-sock failed, continuing"

until docker info >/dev/null 2>&1; do
  echo "Waiting for Docker..."
  sleep 1
done

if [ "${CODESPACES}" = "true" ]; then
  make devcontainer-codespaces || echo "devcontainer-codespaces failed"
else
  make devcontainer || echo "devcontainer failed"
fi

echo "Init done, keeping container alive"
sleep infinity