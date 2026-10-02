FROM local_dev AS project-builder
FROM rust AS rust-build

ARG TARGETPLATFORM

ARG clarinet_version
RUN apk add --no-cache \
    musl-dev build-base \
    linux-headers 

RUN --mount=type=cache,id=local-clarinet-devnet-${TARGETPLATFORM}-cargo-registry,target=/usr/local/cargo/registry,sharing=locked \
    --mount=type=cache,id=local-clarinet-devnet-${TARGETPLATFORM}-cargo-git,target=/usr/local/cargo/git,sharing=locked \
    wget -nv https://github.com/hirosystems/clarinet/archive/refs/tags/v${clarinet_version}.tar.gz && \
    tar -xf v${clarinet_version}.tar.gz && \
    cd clarinet-${clarinet_version}  && \
    cargo clarinet-install

FROM debian
USER root
COPY --from=project-builder /usr/local/bin/localproxy         /usr/local/bin/
COPY --from=rust-build /usr/local/cargo/bin/clarinet          /usr/local/bin/

RUN clarinet completion bash && mv clarinet.bash /etc/bash_completion.d/clarinet.bash && \
    echo 'source /etc/bash_completion.d/clarinet.bash' >> ~/.bashrc

ARG non_root_user=clarinet
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

USER ${non_root_user}
COPY container-entrypoint.sh /usr/local/bin/clarinet-entrypoint.sh
COPY container-install.sh /usr/local/bin/clarinet-container-install.sh
COPY container-start.sh /usr/local/bin/clarinet-devnet-container-start.sh
ENTRYPOINT [ "tini", "--", "clarinet-entrypoint.sh" ]
CMD [ "clarinet-devnet-container-start.sh" ]
HEALTHCHECK CMD test -f /tmp/.clarinet-devnet-runtime-ready || exit 1
