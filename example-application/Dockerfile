FROM builder

USER root

ARG non_root_user=vegito
ARG uid=1000
ARG gid=1000

# 👤 Rename non root user
RUN usermod -l ${non_root_user} ${USER} \
    && groupmod -n ${non_root_user} ${USER} \
    && \
    echo "${non_root_user}:${non_root_user}" | chpasswd && \
    adduser ${non_root_user} sudo && \
    echo "${non_root_user} ALL=(ALL) NOPASSWD:ALL" > /etc/sudoers.d/${non_root_user} && \
    chmod 0440 /etc/sudoers.d/${non_root_user}

USER ${non_root_user}
ENV USER=${non_root_user}

ARG builder_home=/home/debian
ENV HOME=${builder_home}

WORKDIR /src

ENV GOMODCACHE=${HOME}/go/pkg/mod
ENV GOCACHE=${HOME}/.cache/go-build
ENV GOFLAGS="-mod=readonly -trimpath"

COPY backend/go.mod backend/go.sum ./backend/

RUN go work init \
    ./backend 

ARG TARGETPLATFORM
ARG debian_version=bookworm

RUN --mount=type=cache,id=vegito-example-application-${debian_version}-${TARGETPLATFORM}-go-pkg,target=${builder_home}/go/pkg,sharing=locked,uid=${uid},gid=${gid} \
    --mount=type=cache,id=vegito-example-application-${debian_version}-${TARGETPLATFORM}-go-build,target=${builder_home}/.cache/go-build,sharing=locked,uid=${uid},gid=${gid} \
    go work sync && \
    go mod download all && \
    go build -buildmode=archive \
    ./backend/...