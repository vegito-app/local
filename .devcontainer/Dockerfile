ARG builder_image
FROM ${builder_image} AS build

COPY .devcontainer/entrypoint.sh /usr/local/bin/devcontainer-entrypoint.sh

RUN mkdir -p /home/vegito/.vscode-server/extensions
RUN mkdir -p /home/vegito/.vscode-server/bin
RUN mkdir -p /home/vegito/.vscode-server/data

ENTRYPOINT [ "devcontainer-entrypoint.sh" ]
