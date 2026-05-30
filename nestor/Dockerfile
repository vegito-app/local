FROM debian-golang AS go-build
ARG debian_version=bookworm
ARG TARGETPLATFORM

COPY proxy proxy

ARG uid=1000
ARG gid=1000
ARG go_pkg=/home/debian/go/pkg
ARG go_cache=/home/debian/.cache/go-build
ENV GOMODCACHE=${go_pkg}/mod
ENV GOCACHE=${go_cache}
ENV GOBIN=/home/debian/go/bin
ENV CGO_ENABLED=0
RUN --mount=type=cache,id=vegito-debian-${TARGETPLATFORM}-${debian_version}-root-go-pkg,target=${go_pkg},sharing=locked,uid=${uid},gid=${gid} \
    --mount=type=cache,id=vegito-debian-${TARGETPLATFORM}-${debian_version}-root-go-build,target=${go_cache},sharing=locked,uid=${uid},gid=${gid} \
    go install -v 

FROM debian
ARG debian_version=bookworm
ARG TARGETPLATFORM

USER root

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

# 👤 Switch to non root user
USER ${non_root_user}
ENV USER=${non_root_user}

COPY --chown=${uid}:${gid} ./entrypoint.sh /usr/local/bin/nestor-entrypoint.sh
RUN chmod +x /usr/local/bin/nestor-entrypoint.sh 

COPY --chown=${uid}:${gid} ./agent-start.sh /usr/local/bin/nestor-agent-start.sh
RUN chmod +x /usr/local/bin/nestor-agent-start.sh

COPY --chown=${uid}:${gid} ./container-install.sh /usr/local/bin/nestor-container-install.sh
RUN chmod +x /usr/local/bin/nestor-container-install.sh

COPY --chown=${uid}:${gid} ./container-healthcheck.sh /usr/local/bin/nestor-container-healthcheck.sh
RUN chmod +x /usr/local/bin/nestor-container-healthcheck.sh

COPY --from=go-build /home/debian/go/bin/nestor /usr/local/bin/ai-nestor

ENTRYPOINT ["tini", "--", "nestor-entrypoint.sh"]
CMD ["nestor-agent-start.sh"]

HEALTHCHECK CMD /usr/local/bin/nestor-container-healthcheck.sh
WORKDIR /workspaces/ai
