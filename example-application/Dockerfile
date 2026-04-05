FROM builder

ARG non_root_user=vegito
USER ${non_root_user}

WORKDIR /src

ENV GOMODCACHE=/home/${non_root_user}/go/pkg/mod
ENV GOCACHE=/home/${non_root_user}/.cache/go-build
ENV GOFLAGS="-mod=readonly -trimpath"

COPY backend/go.mod backend/go.sum ./backend/

RUN go work init \
    ./backend 

USER root
RUN  --mount=type=cache,id=vegito-go-mod,target=/home/${non_root_user}/go/pkg/mod,sharing=locked \
    --mount=type=cache,id=vegito-go-build,target=/home/${non_root_user}/.cache/go-build,sharing=locked \
    sudo chown -R ${non_root_user}:${non_root_user} \
    /home/${non_root_user}/go/pkg/mod \
    /home/${non_root_user}/.cache/go-build \
    && mkdir -p /home/${non_root_user}/go/pkg/mod \
    && chown -R ${non_root_user}:${non_root_user} \
    /home/${non_root_user}/go/pkg/mod \
    /home/${non_root_user}/.cache/go-build

USER ${non_root_user}

RUN  --mount=type=cache,id=vegito-go-mod,target=/home/${non_root_user}/go/pkg/mod,sharing=locked \
    --mount=type=cache,id=vegito-go-build,target=/home/${non_root_user}/.cache/go-build,sharing=locked \
    go work sync && \
    go mod download all && \
    go build -buildmode=archive \
    ./backend/...