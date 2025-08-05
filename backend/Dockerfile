ARG builder_image=vegito-app:builder-latest
FROM ${builder_image} AS build

ARG non_root_user=dev
USER ${non_root_user}

RUN mkdir -p ${HOME}/src/dev

WORKDIR ${HOME}/src

ARG application_directory="."
ENV APPLICATION_DIR=${application_directory}

COPY Makefile .
COPY git.mk .
RUN mkdir -p application

COPY ${APPLICATION_DIR}/application.mk ./
COPY ${APPLICATION_DIR}/nodejs.mk ./
COPY ${APPLICATION_DIR}/go.mk ./

# frontend
RUN mkdir -p ./frontend
COPY ${APPLICATION_DIR}/frontend/package.json ./frontend/
COPY ${APPLICATION_DIR}/frontend/package-lock.json ./frontend/
COPY ${APPLICATION_DIR}/frontend/frontend.mk ./frontend/

RUN make application-frontend-npm-ci

COPY ${APPLICATION_DIR}/frontend/README.md ./frontend/
COPY ${APPLICATION_DIR}/frontend/public ./frontend/public
COPY ${APPLICATION_DIR}/frontend/src ./frontend/src
COPY ${APPLICATION_DIR}/frontend/webpack.server.js ./frontend/

RUN make -j application-frontend-build application-frontend-bundle

# backend
RUN mkdir -p ./backend

COPY ${APPLICATION_DIR}/backend/backend.mk ./backend/
COPY ${APPLICATION_DIR}/backend/go.sum ./backend/
COPY ${APPLICATION_DIR}/backend/go.mod ./backend/
COPY ${APPLICATION_DIR}/images ./images

RUN make application-go-backend-mod-download

COPY ${APPLICATION_DIR}/backend/btc ./backend/btc
COPY ${APPLICATION_DIR}/backend/firebase ./backend/firebase
COPY ${APPLICATION_DIR}/backend/http ./backend/http
COPY ${APPLICATION_DIR}/backend/internal ./backend/internal
COPY ${APPLICATION_DIR}/backend/log ./backend/log
COPY ${APPLICATION_DIR}/backend/track ./backend/track
COPY ${APPLICATION_DIR}/backend/vault ./backend/vault
COPY ${APPLICATION_DIR}/backend/main.go ./backend/

RUN   make application-backend-install

# artefacts (used if builded with dynamic linkage)
# # x86_64
# FROM scratch AS final-amd64
# COPY --from=build /lib/x86_64-linux-gnu/libstdc++.so.6 /lib/x86_64-linux-gnu/libstdc++.so.6
# COPY --from=build /lib/x86_64-linux-gnu/libstdc++.so.6.0.30 /lib/x86_64-linux-gnu/libstdc++.so.6.0.30
# COPY --from=build /lib/x86_64-linux-gnu/libm.so.6 /lib/x86_64-linux-gnu/libm.so.6
# COPY --from=build /lib/x86_64-linux-gnu/libgcc_s.so.1 /lib/x86_64-linux-gnu/libgcc_s.so.1
# COPY --from=build /lib/x86_64-linux-gnu/libc.so.6 /lib/x86_64-linux-gnu/libc.so.6
# COPY --from=build /lib64/ld-linux-x86-64.so.2 /lib64/ld-linux-x86-64.so.2
# COPY --from=build /lib/x86_64-linux-gnu/ld-linux-x86-64.so.2 /lib/x86_64-linux-gnu/ld-linux-x86-64.so.2

# # arm64
# FROM scratch AS final-arm64
# COPY --from=build /lib/aarch64-linux-gnu/libstdc++.so.6 /lib/aarch64-linux-gnu/libstdc++.so.6
# COPY --from=build /lib/aarch64-linux-gnu/libstdc++.so.6.0.30 /lib/aarch64-linux-gnu/libstdc++.so.6.0.30
# COPY --from=build /lib/aarch64-linux-gnu/libm.so.6 /lib/aarch64-linux-gnu/libm.so.6
# COPY --from=build /lib/aarch64-linux-gnu/libgcc_s.so.1 /lib/aarch64-linux-gnu/libgcc_s.so.1
# COPY --from=build /lib/aarch64-linux-gnu/libc.so.6 /lib/aarch64-linux-gnu/libc.so.6
# COPY --from=build /lib/ld-linux-aarch64.so.1 /lib/ld-linux-aarch64.so.1

# ARG TARGETARCH

# Choix de l'étape finale en fonction de l'architecture
# FROM final-${TARGETARCH} AS final

FROM scratch
ARG builder_home=/home/dev
# Actions supplémentaires à réaliser après la copie des bibliothèques
COPY --from=build /etc/ssl/certs/ca-certificates.crt /etc/ssl/certs/ca-certificates.crt
COPY --from=build /etc/ssl/certs/ca-certificates.crt /etc/ssl/certs/ca-certificates.crt
COPY --from=build ${builder_home}/src/frontend/build/ /frontend/build
COPY --from=build ${builder_home}/src/frontend/public/ /frontend/public
COPY --from=build ${builder_home}/go/bin/backend /backend

ENV FRONTEND_BUILD_DIR=/frontend/build \
    FRONTEND_PUBLIC_DIR=/frontend/public \
    UI_JAVASCRIPT_SOURCE_FILE=/frontend/build/bundle.js

ENTRYPOINT ["/backend"]