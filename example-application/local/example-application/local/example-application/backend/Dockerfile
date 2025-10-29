ARG builder_image="vegito-local:local-builder-latest"
FROM ${builder_image} AS build

RUN mkdir ${HOME}/src
WORKDIR ${HOME}/src

ARG application_directory="example-application"
ENV VEGITO_EXAMPLE_APPLICATION_DIR=${application_directory}

COPY --from=project Makefile .
COPY --from=project local.mk .
COPY --from=project git.mk .
COPY --from=project nodejs.mk .
COPY --from=project go.mk .

RUN mkdir -p example-application/ 
COPY --from=approot example-application.mk example-application/

# frontend
RUN mkdir -p example-application/frontend 
COPY --from=appfrontend package.json example-application/frontend/
COPY --from=appfrontend package-lock.json example-application/frontend/
COPY --from=appfrontend frontend.mk example-application/frontend/

RUN make example-application-frontend-npm-ci

COPY --from=appfrontend public example-application/frontend/public
COPY --from=appfrontend src example-application/frontend/src
COPY --from=appfrontend webpack.server.js example-application/frontend/

RUN make -j example-application-frontend-build example-application-frontend-bundle

# backend
RUN mkdir -p example-application/backend

COPY backend.mk example-application/backend/
COPY go.sum example-application/backend/
COPY go.mod example-application/backend/

RUN make local-go-example-application/backend-mod-download

COPY internal example-application/backend/internal
COPY http example-application/backend/http
COPY log example-application/backend/log
COPY track example-application/backend/track
COPY firebase example-application/backend/firebase
COPY main.go example-application/backend/

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
COPY --from=build /home/${non_root_user}/src/example-application/frontend/build/ /frontend/build
COPY --from=build /home/${non_root_user}/src/example-application/frontend/public/ /frontend/public
COPY --from=build /home/${non_root_user}/go/bin/backend /backend

ENV FRONTEND_BUILD_DIR=/frontend/build \
    FRONTEND_PUBLIC_DIR=/frontend/public \
    UI_JAVASCRIPT_SOURCE_FILE=/frontend/build/bundle.js

ENTRYPOINT ["/backend"]
EXPOSE 8080