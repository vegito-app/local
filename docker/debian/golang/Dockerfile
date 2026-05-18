FROM debian

USER root

ARG go_version
ARG TARGETPLATFORM

RUN set -eux; \
    case "${TARGETPLATFORM}" in \
    "linux/amd64") archive="go${go_version}.linux-amd64.tar.gz" ;; \
    "linux/arm64") archive="go${go_version}.linux-arm64.tar.gz" ;; \
    *) echo "Unsupported TARGETPLATFORM=${TARGETPLATFORM}" && exit 1 ;; \
    esac; \
    url="https://dl.google.com/go/${archive}"; \
    echo "Downloading ${url}, target=${TARGETPLATFORM}"; \
    curl -fSL "${url}" -o /tmp/go.tgz; \
    tar xzf /tmp/go.tgz -C /usr/local; \
    rm -f /tmp/go.tgz

ENV CGO_ENABLED=1
ENV PATH=${PATH}:/usr/local/go/bin

ARG non_root_user=go
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

WORKDIR ${HOME}

# Go tools
RUN  --mount=type=cache,id=local-builder-${TARGETPLATFORM}-go-mod,target=/home/${non_root_user}/go/pkg,sharing=locked,uid=${uid},gid=${gid} \
    --mount=type=cache,id=local-builder-${TARGETPLATFORM}-go-build,target=/home/${non_root_user}/.cache/go-build,sharing=locked,uid=${uid},gid=${gid} \
    GOPATH=/tmp/go GOBIN=${HOME}/bin bash -c " \
    go install -v golang.org/x/tools/gopls@latest \
    && go install -v github.com/cweill/gotests/gotests@v1.6.0 \
    && go install -v github.com/josharian/impl@v1.4.0 \
    && go install -v github.com/haya14busa/goplay/cmd/goplay@v1.0.0 \
    && go install -v github.com/go-delve/delve/cmd/dlv@latest \
    && go install -v honnef.co/go/tools/cmd/staticcheck@latest \
    && go install -v github.com/jesseduffield/lazydocker@latest \
    && go install github.com/oapi-codegen/oapi-codegen/v2/cmd/oapi-codegen@latest \
    "

