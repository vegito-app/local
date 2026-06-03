ARG builder_image
FROM ${builder_image} AS build

COPY .devcontainer/entrypoint.sh /usr/local/bin/devcontainer-entrypoint.sh
COPY .devcontainer/container-install.sh /usr/local/bin/devcontainer-install.sh

ENTRYPOINT [ "devcontainer-entrypoint.sh" ]