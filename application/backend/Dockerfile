ARG builder_image=europe-west1-docker.pkg.dev/moov-438615/prod-docker-repository-public/moov-438615:builder
FROM ${builder_image} AS build

RUN mkdir ${HOME}/src
WORKDIR ${HOME}/src

COPY Makefile .
COPY go.mk .
COPY nodejs.mk .

# frontend
RUN mkdir -p application/frontend 
COPY application/frontend/package.json application/frontend/
COPY application/frontend/package-lock.json application/frontend/
COPY application/frontend/frontend.mk application/frontend/
COPY application/application.mk application/

RUN make application-frontend-npm-ci

COPY application/frontend/README.md application/frontend/
COPY application/frontend/public application/frontend/public
COPY application/frontend/src application/frontend/src
COPY application/frontend/webpack.server.js application/frontend/

RUN make -j application-frontend-build application-frontend-bundle

# backend
RUN mkdir -p application/backend

COPY application/backend/backend.mk application/backend/
COPY application/backend/go.sum application/backend/
COPY application/backend/go.mod application/backend/

RUN make go-application/backend-mod-download

COPY application/backend/internal application/backend/internal
COPY application/backend/http application/backend/http
COPY application/backend/log application/backend/log
COPY application/backend/track application/backend/track
COPY application/backend/firebase application/backend/firebase
COPY application/backend/main.go application/backend/

COPY .git .git
RUN git config --global --add safe.directory ${HOME}/src \
    && make application-backend-install

# artefact
FROM scratch
ARG builder_home=/home/devuser
COPY --from=build /etc/ssl/certs/ca-certificates.crt /etc/ssl/certs/ca-certificates.crt
COPY --from=build ${builder_home}/src/application/frontend/build/ /frontend/build
COPY --from=build ${builder_home}/src/application/frontend/public/ /frontend/public
COPY --from=build ${builder_home}/go/bin/backend /
ENV FRONTEND_BUILD_DIR=/frontend/build \
    FRONTEND_PUBLIC_DIR=/frontend/public \
    UI_JAVASCRIPT_SOURCE_FILE=/frontend/build/bundle.js
ENTRYPOINT ["/backend"]
EXPOSE 8080