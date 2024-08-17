# Build the React App
ARG builder_image=utrade-repository/utrade:builder
FROM --platform=${BUILDPLATFORM} ${builder_image}

WORKDIR ${HOME}/src

COPY local/proxy proxy
RUN cd proxy && go install -v

COPY Makefile .
COPY cloud/cloud.mk cloud/
COPY cloud/infra/auth cloud/infra/auth
COPY local/firebase local/firebase
COPY local/local.mk local/
