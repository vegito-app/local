ARG builder_image=mcr.microsoft.com/vscode/devcontainers/base:ubuntu-22.04
FROM ${builder_image} AS build

COPY .devcontainer/entrypoint.sh /usr/local/bin/devcontainer-entrypoint.sh

ENTRYPOINT [ "devcontainer-entrypoint.sh" ]
