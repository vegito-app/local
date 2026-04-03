FROM debian

ARG non_root_user=trivy

RUN apt-get update && apt-get install -y \
    wget \
    sudo \
    ca-certificates \
    gnupg \
    lsb-release \
    curl \
    && rm -rf /var/lib/apt/lists/*

RUN useradd -m ${non_root_user} -u 1000 && echo "${non_root_user}:${non_root_user}" | chpasswd && adduser ${non_root_user} sudo \
    && echo "${non_root_user} ALL=(ALL) NOPASSWD:ALL" > /etc/sudoers.d/${non_root_user} \
    && chmod 0440 /etc/sudoers.d/${non_root_user}

ARG trivy_version

# Install Trivy
RUN wget -qO - https://aquasecurity.github.io/trivy-repo/deb/public.key | gpg --dearmor -o /usr/share/keyrings/trivy.gpg \
    && echo "deb [signed-by=/usr/share/keyrings/trivy.gpg] https://aquasecurity.github.io/trivy-repo/deb $(lsb_release -sc) main" \
    | tee /etc/apt/sources.list.d/trivy.list \
    && apt-get update \
    && apt-get install -y trivy=${trivy_version} \
    && rm -rf /var/lib/apt/lists/*

COPY entrypoint.sh /usr/local/bin/entrypoint.sh
RUN chmod +x /usr/local/bin/entrypoint.sh

COPY entrypoint.sh /usr/local/bin/entrypoint.sh
RUN chmod +x /usr/local/bin/entrypoint.sh

ENV HOME=/home/${non_root_user}
WORKDIR ${HOME}
RUN chown -R ${non_root_user}:${non_root_user} ${HOME}
USER ${non_root_user}
ENTRYPOINT ["trivy"]