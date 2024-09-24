# Build the React App
ARG builder_image=docker-repository-public/main:builder

FROM --platform=${BUILDPLATFORM} ${builder_image} AS build

WORKDIR ${HOME}/src

COPY .git .git
RUN git config --global --add safe.directory ${HOME}/src

COPY Makefile .
COPY go.mk .

# Backend
COPY backend/backend.mk backend/
COPY backend/go.* backend/
RUN make go-backend-mod-download
COPY backend/internal backend/internal
COPY backend/http backend/http
COPY backend/log backend/log
COPY backend/track backend/track
COPY backend/firebase backend/firebase
COPY backend/main.go backend/
RUN make backend-install

COPY nodejs.mk .

# Frontend
RUN mkdir -p frontend/node_modules
COPY frontend/package-lock.json frontend/
COPY frontend/package.json frontend/
COPY frontend/frontend.mk frontend/
USER root
RUN make frontend-node-modules # frontend-npm-ci
USER devuser

COPY frontend/README.md frontend/
COPY frontend/public frontend/public
COPY frontend/src frontend/src
COPY frontend/webpack.server.js frontend/


COPY frontend/docker-build.sh frontend/
RUN --mount=type=secret,id=google_maps_api_key ./frontend/docker-build.sh

# final container
FROM scratch
COPY --from=build /home/devuser/src/frontend/build/ /frontend/build
COPY --from=build /home/devuser/src/frontend/public/ /frontend/public
COPY --from=build /home/devuser/go/bin/backend /
ENV FRONTEND_BUILD_DIR=/frontend/build \
    FRONTEND_PUBLIC_DIR=/frontend/public \
    UI_JAVASCRIPT_SOURCE_FILE=/frontend/build/bundle.js
ENTRYPOINT ["/backend"]
EXPOSE 8080