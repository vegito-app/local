FROM debian

USER root

ARG TARGETPLATFORM

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

COPY ./stripe-start.sh /usr/local/bin/local-stripe-start.sh
RUN chmod +x /usr/local/bin/local-stripe-start.sh

USER ${non_root_user}
ENV HOME=/home/${non_root_user}
WORKDIR ${HOME}

CMD ["local-stripe-start.sh"]