ARG builder_image=europe-west1-docker.pkg.dev/moov-dev-439608/docker-repository-public/moov-dev-439608:builder-latest
FROM ${builder_image} AS build

COPY .devcontainer/entrypoint.sh /usr/local/bin/devcontainer-entrypoint.sh

ENTRYPOINT [ "devcontainer-entrypoint.sh" ]
