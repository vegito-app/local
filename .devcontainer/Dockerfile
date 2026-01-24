ARG builder_image
FROM ${builder_image} AS build

COPY .devcontainer/entrypoint.sh /usr/local/bin/devcontainer-entrypoint.sh

RUN mkdir -p /home/vegito/.vscode-server/extensions
RUN mkdir -p /home/vegito/.vscode-server/bin
RUN mkdir -p /home/vegito/.vscode-server/data

ARG VSCODE_COMMIT=c9d77990917f3102ada88be140d28b038d1dd7c7

RUN mkdir -p /home/vegito/.vscode-server/bin/${VSCODE_COMMIT} \
    && curl -L https://update.code.visualstudio.com/commit:${VSCODE_COMMIT}/server-linux-x64/stable \
    | tar -xz -C /home/vegito/.vscode-server/bin/${VSCODE_COMMIT} --strip-components=1

ENTRYPOINT [ "devcontainer-entrypoint.sh" ]
