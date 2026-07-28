FROM debian

ARG TARGETPLATFORM

ARG debian_version=bookworm

USER root

RUN --mount=type=cache,id=local-vault-dev-${TARGETPLATFORM}-apt-cache,target=/var/cache/apt,sharing=locked \
    --mount=type=cache,id=local-vault-dev-${TARGETPLATFORM}-apt-lib,target=/var/lib/apt,sharing=locked \
    curl -fsSL https://apt.releases.hashicorp.com/gpg | gpg --dearmor -o /usr/share/keyrings/hashicorp-archive-keyring.gpg \
    && echo "deb [arch=$(dpkg --print-architecture) signed-by=/usr/share/keyrings/hashicorp-archive-keyring.gpg] https://apt.releases.hashicorp.com ${debian_version} main" \
    | tee /etc/apt/sources.list.d/hashicorp.list \
    && apt-get -o Acquire::Retries=3 update && apt-get install -y vault

ARG non_root_user=vault-dev
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

COPY entrypoint.sh /usr/local/bin/vault-local-entrypoint.sh

ENV VAULT_ADDR=http://127.0.0.1:8200

ENTRYPOINT ["vault-local-entrypoint.sh"]
