
FROM debian
ARG debian_version=bookworm
ARG TARGETPLATFORM

USER root

RUN --mount=type=cache,id=vegito-debian-${debian_version}-${TARGETPLATFORM}-apt-cache,target=/var/cache/apt,sharing=locked \
    --mount=type=cache,id=vegito-debian-${debian_version}-${TARGETPLATFORM}-apt-lib,target=/var/lib/apt,sharing=locked \
    mkdir -p /etc/apt/keyrings && \
    curl -fsSL https://packages.microsoft.com/keys/microsoft.asc \
    | gpg --dearmor \
    > /etc/apt/keyrings/packages.microsoft.gpg && \
    chmod go+r /etc/apt/keyrings/packages.microsoft.gpg && \
    if [ "${TARGETPLATFORM}" = "linux/amd64" ]; then \
    echo "deb [arch=amd64 signed-by=/etc/apt/keyrings/packages.microsoft.gpg] https://packages.microsoft.com/repos/code stable main" \
    > /etc/apt/sources.list.d/vscode.list && \
    apt-get update && \
    apt-get install -y code ; \
    else \
    echo "Skipping VSCode install on $TARGETPLATFORM" ; \
    fi

# 👤 Create non root user
ARG non_root_user=nestor
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

ARG docker_compose_version
ARG docker_buildx_version \
    # 
    # Docker Buildx 
    # 
    case "$TARGETPLATFORM" in \
    "linux/amd64") \
    url="https://github.com/docker/buildx/releases/download/v${docker_buildx_version}/buildx-v${docker_buildx_version}.linux-amd64"; \
    sha256='805195386fba0cea5a1487cf0d47da82a145ea0a792bd3fb477583e2dbcdcc2f'; \
    ;; \
    "linux/arm64") \
    url="https://github.com/docker/buildx/releases/download/v${docker_buildx_version}/buildx-v${docker_buildx_version}.linux-arm64"; \
    sha256='6e9e455b5ec1c7ac708f2640a86c5cecce38c72e48acff6cb219dfdfa2dda781'; \
    ;; \
    *) echo >&2 "warning: unsupported 'docker-buildx' architecture ($TARGETPLATFORM); skipping"; exit 0 ;; \
    esac; \
    \
    wget -O 'docker-buildx' "$url"; \
    echo "$sha256 *"'docker-buildx' | sha256sum -c -; \
    \
    plugin='/usr/local/libexec/docker/cli-plugins/docker-buildx'; \
    mkdir -p "$(dirname "$plugin")"; \
    mv -vT 'docker-buildx' "$plugin"; \
    chmod +x "$plugin"; \
    \
    docker buildx version ; \
    #
    # Docker Compose
    # 
    \
    case "$TARGETPLATFORM" in \
    "linux/amd64") \
    url="https://github.com/docker/compose/releases/download/v${docker_compose_version}/docker-compose-linux-x86_64"; \
    sha256='94a416c6f2836a0a1ba5eb3feb00f2e700a9d98311f062c4c61494ccbf3cd457'; \
    ;; \
    "linux/arm64") \
    url="https://github.com/docker/compose/releases/download/v${docker_compose_version}/docker-compose-linux-aarch64"; \
    sha256='cd1ef5eda1119edb9314c0224bac97cee14a9c31909a0f7aa0ddfe266e08adaa'; \
    ;; \
    *) echo >&2 "warning: unsupported 'docker-compose' architecture ($TARGETPLATFORM); skipping"; exit 0 ;; \
    esac; \
    \
    wget -O 'docker-compose' "$url"; \
    echo "$sha256 *"'docker-compose' | sha256sum -c -; \
    \
    plugin='/usr/local/libexec/docker/cli-plugins/docker-compose'; \
    mkdir -p "$(dirname "$plugin")"; \
    mv -vT 'docker-compose' "$plugin"; \
    chmod +x "$plugin"; \
    \
    ln -sv "$plugin" /usr/local/bin/; \
    docker-compose --version; \
    docker compose version

# 👤 Switch to non root user
USER ${non_root_user}
ENV USER=${non_root_user}

ARG uid=1000
ARG gid=1000

COPY --chown=${uid}:${gid} ./entrypoint.sh /usr/local/bin/nestor-entrypoint.sh
RUN chmod +x /usr/local/bin/nestor-entrypoint.sh 

COPY --chown=${uid}:${gid} ./agent-start.sh /usr/local/bin/nestor-agent-start.sh
RUN chmod +x /usr/local/bin/nestor-agent-start.sh

COPY --chown=${uid}:${gid} ./container-install.sh /usr/local/bin/nestor-container-install.sh
RUN chmod +x /usr/local/bin/nestor-container-install.sh

COPY --chown=${uid}:${gid} ./container-healthcheck.sh /usr/local/bin/nestor-container-healthcheck.sh
RUN chmod +x /usr/local/bin/nestor-container-healthcheck.sh

ENTRYPOINT ["tini", "--", "nestor-entrypoint.sh"]
CMD ["nestor-agent-start.sh"]

HEALTHCHECK CMD /usr/local/bin/nestor-container-healthcheck.sh
WORKDIR /workspaces/ai
