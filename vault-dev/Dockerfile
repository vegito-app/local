FROM debian

RUN --mount=type=cache,id=local-vault-dev-${TARGETPLATFORM}-apt-cache,target=/var/cache/apt,sharing=locked \
    --mount=type=cache,id=local-vault-dev-${TARGETPLATFORM}-apt-lib,target=/var/lib/apt,sharing=locked \
    apt-get update && apt-get install -y \
    curl \
    gpg \
    htop \
    jq \
    lsb-release \
    make \
    netcat-openbsd \
    sudo \
    wget

ARG non_root_user=vault

RUN useradd -m ${non_root_user} -u 1000 && echo "${non_root_user}:${non_root_user}" | chpasswd && adduser ${non_root_user} sudo \
    && echo "${non_root_user} ALL=(ALL) NOPASSWD:ALL" > /etc/sudoers.d/${non_root_user} \
    && chmod 0440 /etc/sudoers.d/${non_root_user} \
    \
    && chown -R ${non_root_user}:${non_root_user} ${HOME}

ENV HOME=/home/${non_root_user}

RUN --mount=type=cache,id=local-vault-dev-${TARGETPLATFORM}-apt-cache,target=/var/cache/apt,sharing=locked \
    --mount=type=cache,id=local-vault-dev-${TARGETPLATFORM}-apt-lib,target=/var/lib/apt,sharing=locked \
    wget -O - https://apt.releases.hashicorp.com/gpg | gpg --dearmor -o /usr/share/keyrings/hashicorp-archive-keyring.gpg \
    && echo "deb [arch=$(dpkg --print-architecture) signed-by=/usr/share/keyrings/hashicorp-archive-keyring.gpg] https://apt.releases.hashicorp.com $(lsb_release -cs) main" \
    | tee /etc/apt/sources.list.d/hashicorp.list \
    && apt-get update && apt-get install -y vault

WORKDIR ${HOME}

RUN ln -sf /usr/bin/bash /bin/sh
USER ${non_root_user}

COPY entrypoint.sh /usr/local/bin/vault-local-entrypoint.sh

ENV VAULT_ADDR=http://127.0.0.1:8200

ENTRYPOINT ["vault-local-entrypoint.sh"]
