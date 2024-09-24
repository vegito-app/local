# Build the React App
ARG builder_image=docker-repository-public/main:builder
FROM --platform=${BUILDPLATFORM} ${builder_image}
# USER root
# RUN  npm uninstall firebase-tools &&  npm install -g firebase-tools@latest

# USER devuser
WORKDIR ${HOME}/src

COPY local/proxy proxy
RUN cd proxy && go install -v

COPY Makefile .
COPY gcloud/gcloud.mk gcloud/
COPY gcloud/infra/auth gcloud/infra/auth
COPY local/firebase local/firebase
COPY local/local.mk local/
