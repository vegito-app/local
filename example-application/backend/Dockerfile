ARG builder_image="vegito-local:local-builder-latest"
FROM ${builder_image} AS build

RUN mkdir ${HOME}/src ${HOME}/src/local
WORKDIR ${HOME}/src

COPY --from=approot Makefile .
COPY --from=approot local/local.mk local/
COPY --from=approot git.mk .
COPY --from=approot nodejs.mk .
COPY --from=approot go.mk .

COPY --from=approot example-application.mk .

# frontend
RUN mkdir -p frontend 
COPY --from=appfrontend package.json frontend/
COPY --from=appfrontend package-lock.json frontend/
COPY --from=appfrontend frontend.mk frontend/

RUN make example-application-frontend-npm-ci

COPY --from=appfrontend public frontend/public
COPY --from=appfrontend src frontend/src
COPY --from=appfrontend webpack.server.js frontend/

RUN make -j example-application-frontend-build example-application-frontend-bundle

# backend
RUN mkdir -p backend

COPY backend.mk backend/
COPY go.sum backend/
COPY go.mod backend/

RUN make example-application-go-backend-mod-download

COPY internal backend/internal
COPY http backend/http
COPY log backend/log
COPY track backend/track
COPY firebase backend/firebase
COPY main.go backend/

RUN make example-application-backend-install 

# artefacts

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
ARG non_root_user=vegito
ARG builder_home=/home/${non_root_user}

COPY --from=build /etc/ssl/certs/ca-certificates.crt /etc/ssl/certs/ca-certificates.crt
COPY --from=build /etc/ssl/certs/ca-certificates.crt /etc/ssl/certs/ca-certificates.crt
COPY --from=build /home/${non_root_user}/src/frontend/build/ /frontend/build
COPY --from=build /home/${non_root_user}/src/frontend/public/ /frontend/public
COPY --from=build /home/${non_root_user}/go/bin/backend /backend

ENV FRONTEND_BUILD_DIR=/frontend/build \
    FRONTEND_PUBLIC_DIR=/frontend/public \
    UI_JAVASCRIPT_SOURCE_FILE=/frontend/build/bundle.js

ENTRYPOINT ["/backend"]
EXPOSE 8080