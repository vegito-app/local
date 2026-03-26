ARG local_builder_image=vegito-app:builder-latest
FROM ${local_builder_image} AS global-gomods

ARG non_root_user=vegito
USER ${non_root_user}

WORKDIR /src

ENV GOMODCACHE=/home/${non_root_user}/go/pkg/mod
ENV GOCACHE=/home/${non_root_user}/.cache/go-build
ENV GOFLAGS="-mod=readonly -trimpath"

COPY backend/go.mod backend/go.sum backend/
# COPY other/go.mod other/go.sum other/
# COPY module/go.mod module/go.sum module/

RUN go work init \
    ./backend 
# ./other \
# ./module

USER root
RUN  --mount=type=cache,id=vegito-go-mod,target=/home/${non_root_user}/go/pkg/mod,sharing=locked \
    --mount=type=cache,id=vegito-go-build,target=/home/${non_root_user}/.cache/go-build,sharing=locked \
    chown -R ${non_root_user}:${non_root_user} \
    /home/${non_root_user}/go \
    /home/${non_root_user}/.cache/go-build

USER ${non_root_user}

RUN  --mount=type=cache,id=vegito-go-mod,target=/home/${non_root_user}/go/pkg/mod,sharing=locked \
    --mount=type=cache,id=vegito-go-build,target=/home/${non_root_user}/.cache/go-build,sharing=locked \
    go work sync && \
    go mod download all && \
    go build -buildmode=archive \
    ./backend/...
# ./other/... \
# ./module/...