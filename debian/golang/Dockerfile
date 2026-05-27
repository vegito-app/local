FROM dockerhub_golang AS go-build

ARG debian_version=bookworm
ARG TARGETPLATFORM

ARG go_pkg=/go/pkg
ARG go_cache=/.cache
ENV GOMODCACHE=${go_pkg}/mod
ENV GOCACHE=${go_cache}
ENV GOBIN=/go/bin
ENV CGO_ENABLED=0
RUN --mount=type=cache,id=vegito-debian-${TARGETPLATFORM}-${debian_version}-root-go-pkg,target=${go_pkg},sharing=locked \
    --mount=type=cache,id=vegito-debian-${TARGETPLATFORM}-${debian_version}-root-go-build,target=${go_cache},sharing=locked \
    go install -v github.com/vegito-app/local/proxy@latest \
    && go install -v github.com/go-delve/delve/cmd/dlv@latest \
    && go install -v honnef.co/go/tools/cmd/staticcheck@latest \
    && go install -v github.com/jesseduffield/lazydocker@latest \
    && go install -v github.com/oapi-codegen/oapi-codegen/v2/cmd/oapi-codegen@latest \
    && go install -v golang.org/x/tools/gopls@latest \
    && go install -v github.com/cweill/gotests/gotests@v1.6.0 \
    && go install -v github.com/josharian/impl@v1.4.0 \
    && go install -v github.com/haya14busa/goplay/cmd/goplay@v1.0.0

FROM debian

ARG non_root_user=go
ARG uid=1000
ARG gid=1000

USER root

# 👤 Rename non root user
RUN usermod -l ${non_root_user} ${USER} \
    && groupmod -n ${non_root_user} ${USER} \
    && \
    echo "${non_root_user}:${non_root_user}" | chpasswd && \
    adduser ${non_root_user} sudo && \
    echo "${non_root_user} ALL=(ALL) NOPASSWD:ALL" > /etc/sudoers.d/${non_root_user} && \
    chmod 0440 /etc/sudoers.d/${non_root_user}

COPY --from=go-build /usr/local/go/ /usr/local/go/
ENV CGO_ENABLED=0

USER ${non_root_user} 
ENV USER=${non_root_user}
COPY --chown=${uid}:${gid} --from=go-build /go/bin/ /home/debian/go/bin/

ENV PATH=${PATH}:/usr/local/go/bin
RUN mkdir -p /home/debian/go/bin
ENV PATH=${PATH}:/home/debian/go/bin