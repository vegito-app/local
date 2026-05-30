
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

ENTRYPOINT ["tini", "--", "nestor-entrypoint.sh"]
CMD ["nestor-agent-start.sh"]

HEALTHCHECK CMD /usr/local/bin/nestor-container-healthcheck.sh
WORKDIR /workspaces/ai
