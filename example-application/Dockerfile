FROM builder

ARG non_root_user=vegito
ARG uid=1000
ARG gid=1000

USER ${non_root_user}

WORKDIR /src

ENV GOMODCACHE=/home/${non_root_user}/go/pkg/mod
ENV GOCACHE=/home/${non_root_user}/.cache/go-build
ENV GOFLAGS="-mod=readonly -trimpath"

COPY backend/go.mod backend/go.sum ./backend/

RUN go work init \
    ./backend 

RUN --mount=type=cache,id=vegito-local-example-application-${TARGETPLATFORM}-go-mod,target=/home/${non_root_user}/go/pkg,sharing=locked,uid=${uid},gid=${gid} \
    --mount=type=cache,id=vegito-local-example-application-${TARGETPLATFORM}-go-mod,target=/home/${non_root_user}/.cache/go-build,sharing=locked,uid=${uid},gid=${gid} \
    go work sync && \
    go mod download all && \
    go build -buildmode=archive \
    ./backend/...