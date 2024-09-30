# Build the React App
ARG builder_image=docker-repository-public/utrade:builder
FROM --platform=${BUILDPLATFORM} ${builder_image}

WORKDIR ${HOME}/src

COPY local/proxy proxy
RUN cd proxy && go install -v

COPY Makefile .
COPY infra/infra.mk infra/infra.mk 
COPY infra/gcloud/gcloud.mk infra/gcloud/gcloud.mk 
COPY infra/gcloud/auth infra/gcloud/auth
COPY local/firebase local/firebase
COPY local/local.mk local/
