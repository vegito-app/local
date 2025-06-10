# application/cleaner/Dockerfile
ARG builder_image=europe-west1-docker.pkg.dev/moov-dev-439608/docker-repository-public/moov-dev-439608:builder-latest
FROM ${builder_image} AS build

ARG non_root_user=dev
USER ${non_root_user}

RUN mkdir -p ${HOME}/src/dev

WORKDIR ${HOME}/src

RUN mkdir -p application/images/cleaner

COPY Makefile .
RUN mkdir -p application
COPY application/application.mk ./application/application.mk
COPY application/go.mk ./application/go.mk
COPY application/images/images.mk ./application/images/images.mk
COPY application/images/cleaner/cleaner.mk ./application/images/cleaner/cleaner.mk

COPY application/images application/images

RUN make go-application/images-mod-download
# COPY .git .git

RUN \
    git config --global --add safe.directory ${HOME}/src && \
    make application-images-cleaner-install

FROM scratch
ARG builder_home=/home/dev
# Actions supplémentaires à réaliser après la copie des bibliothèques
COPY --from=build /etc/ssl/certs/ca-certificates.crt /etc/ssl/certs/ca-certificates.crt
COPY --from=build /etc/ssl/certs/ca-certificates.crt /etc/ssl/certs/ca-certificates.crt
COPY --from=build ${builder_home}/go/bin/cleaner /usr/bin/application-images-cleaner
ENTRYPOINT ["/usr/bin/application-images-cleaner"]