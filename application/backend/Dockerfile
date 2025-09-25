ARG builder_image="vegito-local:local-builder-latest"
FROM ${builder_image} AS build

RUN mkdir ${HOME}/src
WORKDIR ${HOME}/src

ARG application_directory="application"
ENV LOCAL_APPLICATION_DIR=${application_directory}

COPY --from=project Makefile .
COPY --from=project local.mk .
COPY --from=project git.mk .
COPY --from=project nodejs.mk .
COPY --from=project go.mk .

RUN mkdir -p application/ 
COPY --from=approot application.mk application/

# frontend
RUN mkdir -p application/frontend 
COPY --from=appfrontend package.json application/frontend/
COPY --from=appfrontend package-lock.json application/frontend/
COPY --from=appfrontend frontend.mk application/frontend/

RUN make local-application-frontend-npm-ci

COPY --from=appfrontend public application/frontend/public
COPY --from=appfrontend src application/frontend/src
COPY --from=appfrontend webpack.server.js application/frontend/

RUN make -j local-application-frontend-build local-application-frontend-bundle

# backend
RUN mkdir -p application/backend

COPY backend.mk application/backend/
COPY go.sum application/backend/
COPY go.mod application/backend/

RUN make local-go-application/backend-mod-download

COPY internal application/backend/internal
COPY http application/backend/http
COPY log application/backend/log
COPY track application/backend/track
COPY firebase application/backend/firebase
COPY main.go application/backend/

RUN make local-application-backend-install 

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
COPY --from=build /home/${non_root_user}/src/application/frontend/build/ /frontend/build
COPY --from=build /home/${non_root_user}/src/application/frontend/public/ /frontend/public
COPY --from=build /home/${non_root_user}/go/bin/backend /backend

ENV FRONTEND_BUILD_DIR=/frontend/build \
    FRONTEND_PUBLIC_DIR=/frontend/public \
    UI_JAVASCRIPT_SOURCE_FILE=/frontend/build/bundle.js

ENTRYPOINT ["/backend"]
EXPOSE 8080