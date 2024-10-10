ARG builder_image=docker-repository-public/utrade:builder
FROM --platform=${BUILDPLATFORM} ${builder_image} AS build

RUN mkdir ${HOME}/src
WORKDIR ${HOME}/src

COPY Makefile .
COPY go.mk .
COPY go.mk .
RUN mkdir application
COPY application/application.mk application/


# Frontend
RUN mkdir application/frontend
COPY application/frontend/package-lock.json application/frontend/
COPY application/frontend/package.json application/frontend/
COPY application/frontend/frontend.mk application/frontend/
COPY nodejs.mk .

RUN sudo chmod o+rw application/frontend/package-lock.json \
    && make application/frontend-node-modules application-frontend-npm-ci

COPY application/frontend/README.md application/frontend/
COPY application/frontend/public application/frontend/public
COPY application/frontend/src application/frontend/src
COPY application/frontend/webpack.server.js application/frontend/

RUN make application-frontend-build application-frontend-bundle

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