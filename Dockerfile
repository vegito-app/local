# Build the React App
ARG builder_image=utrade-repository/utrade:builder

FROM --platform=${BUILDPLATFORM} ${builder_image} AS build

WORKDIR ${HOME}/src/
COPY Makefile .
COPY backend/backend.mk backend/
COPY backend/go.* backend/
COPY backend/vendor backend/vendor
COPY backend/internal backend/internal
COPY backend/http backend/http
COPY backend/track backend/track
COPY backend/firebase backend/firebase
COPY backend/main.go backend/
RUN make backend-install
COPY frontend frontend
COPY frontend/frontend.mk frontend/
COPY frontend/package.json frontend/package-lock.json frontend/
COPY .git .git
RUN git config --global --add safe.directory .
RUN make frontend-npm-ci

ARG REACT_APP_UTRADE_VERSION
ARG REACT_APP_UTRADE_FIREBASE_API_KEY
ARG REACT_APP_UTRADE_FIREBASE_AUTH_DOMAIN
ARG REACT_APP_UTRADE_FIREBASE_DATABASE_URL
ARG REACT_APP_UTRADE_FIREBASE_PROJECT_ID
ARG REACT_APP_UTRADE_FIREBASE_STORAGE_BUCKET
ARG REACT_APP_UTRADE_FIREBASE_MESSAGING_SENDER_ID
ARG REACT_APP_UTRADE_FIREBASE_APP_ID

ENV REACT_APP_UTRADE_VERSION=$REACT_APP_UTRADE_VERSION
ENV REACT_APP_UTRADE_FIREBASE_API_KEY=$REACT_APP_UTRADE_FIREBASE_API_KEY
ENV REACT_APP_UTRADE_FIREBASE_AUTH_DOMAIN=$REACT_APP_UTRADE_FIREBASE_AUTH_DOMAIN
ENV REACT_APP_UTRADE_FIREBASE_DATABASE_URL=$REACT_APP_UTRADE_FIREBASE_DATABASE_URL
ENV REACT_APP_UTRADE_FIREBASE_PROJECT_ID=$REACT_APP_UTRADE_FIREBASE_PROJECT_ID
ENV REACT_APP_UTRADE_FIREBASE_STORAGE_BUCKET=$REACT_APP_UTRADE_FIREBASE_STORAGE_BUCKET
ENV REACT_APP_UTRADE_FIREBASE_MESSAGING_SENDER_ID=$REACT_APP_UTRADE_FIREBASE_MESSAGING_SENDER_ID
ENV REACT_APP_UTRADE_FIREBASE_APP_ID=$REACT_APP_UTRADE_FIREBASE_APP_ID

RUN --mount=type=secret,id=google_maps_api_key ./frontend/docker-build.sh

FROM scratch
COPY --from=build /home/devuser/src/frontend/build/ /frontend/build
COPY --from=build /home/devuser/src/frontend/public/ /frontend/public
ENV FRONTEND_BUILD_DIR=/frontend/build
ENV FRONTEND_PUBLIC_DIR=/frontend/public
ENV UI_JAVASCRIPT_SOURCE_FILE=/frontend/build/bundle.js
COPY --from=build /home/devuser/go/bin/backend /
ENTRYPOINT ["/backend"]
EXPOSE 8080