FROM debian

USER root

ARG TARGETPLATFORM

RUN --mount=type=cache,id=local-stripe-${TARGETPLATFORM}-apt-cache,target=/var/cache/apt,sharing=locked \
    --mount=type=cache,id=local-stripe-${TARGETPLATFORM}-apt-lib,target=/var/lib/apt,sharing=locked \
    apt-get -o Acquire::Retries=3 update && apt-get install -y \
    ca-certificates \
    curl \
    gnupg \
    lsb-release \
    procps\
    sudo \
    wget

# Install Stripe CLI
RUN --mount=type=cache,id=local-builder-${TARGETPLATFORM}-apt-cache,target=/var/cache/apt,sharing=locked \
    --mount=type=cache,id=local-builder-${TARGETPLATFORM}-apt-lib,target=/var/lib/apt,sharing=locked \
    curl -fsSL https://packages.stripe.dev/api/security/keypair/stripe-cli-gpg/public | gpg --dearmor -o /usr/share/keyrings/stripe.gpg && \
    echo "deb [signed-by=/usr/share/keyrings/stripe.gpg] https://packages.stripe.dev/stripe-cli-debian-local stable main" | sudo tee -a /etc/apt/sources.list.d/stripe.list && \
    apt-get update -o Acquire::Retries=3 && apt-get install -y stripe && \
    rm -rf /var/lib/apt/lists/*

ARG non_root_user=stripe
ARG uid=1000
ARG gid=1000

RUN groupadd -g ${gid} ${non_root_user} \
    && useradd -m -u ${uid} -g ${gid} ${non_root_user} \
    && echo "${non_root_user}:${non_root_user}" | chpasswd && adduser ${non_root_user} sudo \
    && echo "${non_root_user} ALL=(ALL) NOPASSWD:ALL" > /etc/sudoers.d/${non_root_user} \
    && chmod 0440 /etc/sudoers.d/${non_root_user}

COPY ./entrypoint.sh /usr/local/bin/vegito-local-stripe-entrypoint.sh
RUN chmod +x /usr/local/bin/vegito-local-stripe-entrypoint.sh

USER ${non_root_user}
ENV HOME=/home/${non_root_user}
WORKDIR ${HOME}

ENTRYPOINT ["vegito-local-stripe-entrypoint.sh"]