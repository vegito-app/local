FROM debian_project_builder

USER root

ARG non_root_user=local

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

WORKDIR /home/debian/src

ENV GOMODCACHE=/home/debian/go/pkg/mod
ENV GOCACHE=/home/debian/.cache/go-build
ENV GOFLAGS="-mod=readonly"

COPY example-application/backend/go.mod example-application/backend/go.sum example-application/backend/
COPY proxy/go.mod proxy/go.sum proxy/

RUN go work init \
    ./example-application/backend \
    ./proxy

ARG TARGETPLATFORM
ARG debian_version=bookworm

RUN --mount=type=cache,id=vegito-app-${TARGETPLATFORM}-${debian_version}-go-pkg,target=/home/debian/go/pkg,sharing=locked,uid=${uid},gid=${gid} \
    --mount=type=cache,id=vegito-app-${TARGETPLATFORM}-${debian_version}-go-build,target=/home/debian/.cache/go-build,sharing=locked,uid=${uid},gid=${gid} \
    go work sync && \
    go mod download all && \
    go build -buildmode=archive \
    ./example-application/backend/... \
    ./proxy/...

COPY dev-container-entrypoint.sh /usr/local/bin/local-builder-entrypoint.sh
COPY dev-container-start.sh /usr/local/bin/local-builder-start.sh

ENTRYPOINT ["tini","--","local-builder-entrypoint.sh"]
CMD  ["local-builder-start.sh"]