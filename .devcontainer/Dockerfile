ARG builder_image
FROM ${builder_image} AS build

COPY .devcontainer/entrypoint.sh /usr/local/bin/devcontainer-entrypoint.sh

ENTRYPOINT [ "devcontainer-entrypoint.sh" ]
