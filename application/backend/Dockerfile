ARG builder_image=europe-west1-docker.pkg.dev/moov-438615/prod-docker-repository-public/moov-438615:builder
FROM ${builder_image} AS build

RUN mkdir ${HOME}/src
WORKDIR ${HOME}/src

COPY Makefile .
COPY go.mk .
COPY go.mk .
RUN mkdir application
COPY application/application.mk application/

USER root

# Frontend
RUN mkdir -p application/frontend 
# COPY application/frontend/package-lock.json application/frontend/
COPY application/frontend/package.json application/frontend/
COPY application/frontend/frontend.mk application/frontend/
COPY nodejs.mk .

COPY .git .git
RUN  git config --global --add safe.directory /home/devuser/src
COPY application/frontend/package-lock.json application/frontend/package-lock.json

COPY application/frontend/node_modules application/frontend/node_modules

# RUN bash -c '. /home/devuser/nvm/nvm.sh && make application/frontend-node-modules'
# RUN bash -c '. /home/devuser/nvm/nvm.sh && make application-frontend-npm-ci'

COPY application/frontend/README.md application/frontend/
COPY application/frontend/public application/frontend/public
COPY application/frontend/src application/frontend/src
COPY application/frontend/webpack.server.js application/frontend/

RUN bash -c ' \
    . /home/devuser/nvm/nvm.sh \
    && make application-frontend-build \
    && make application-frontend-bundle \
    '

RUN bash -c '. /home/devuser/nvm/nvm.sh && make application-frontend-bundle'

# Backend
RUN mkdir application/backend
COPY application/backend/backend.mk application/backend/
COPY application/backend/go.* application/backend/
RUN make go-application/backend-mod-download
COPY application/backend/internal application/backend/internal
COPY application/backend/http application/backend/http
COPY application/backend/log application/backend/log
COPY application/backend/track application/backend/track
COPY application/backend/firebase application/backend/firebase
COPY application/backend/main.go application/backend/
RUN make application-backend-install

# application container
FROM scratch

COPY --from=build /etc/ssl/certs/ca-certificates.crt /etc/ssl/certs/ca-certificates.crt
COPY --from=build /home/devuser/src/application/frontend/build/ /frontend/build
COPY --from=build /home/devuser/src/application/frontend/public/ /frontend/public
COPY --from=build /home/devuser/go/bin/backend /
ENV FRONTEND_BUILD_DIR=/frontend/build \
    FRONTEND_PUBLIC_DIR=/frontend/public \
    UI_JAVASCRIPT_SOURCE_FILE=/frontend/build/bundle.js
ENTRYPOINT ["/backend"]
EXPOSE 8080