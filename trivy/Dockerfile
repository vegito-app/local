FROM debian


RUN --mount=type=cache,id=local-trivy-${TARGETPLATFORM}-apt-cache,target=/var/cache/apt,sharing=locked \
    --mount=type=cache,id=local-trivy-${TARGETPLATFORM}-apt-lib,target=/var/lib/apt,sharing=locked \
    apt-get -o Acquire::Retries=3 update && apt-get install -y \
    wget \
    sudo \
    ca-certificates \
    gnupg \
    lsb-release \
    curl

ARG non_root_user=trivy
ARG uid=1000
ARG gid=1000

RUN groupadd -g ${gid} ${non_root_user} \
    && useradd -m -u ${uid} -g ${gid} ${non_root_user} \
    && echo "${non_root_user}:${non_root_user}" | chpasswd && adduser ${non_root_user} sudo \
    && echo "${non_root_user} ALL=(ALL) NOPASSWD:ALL" > /etc/sudoers.d/${non_root_user} \
    && chmod 0440 /etc/sudoers.d/${non_root_user}

# Install Trivy
ARG trivy_version=0.70.0

RUN wget https://github.com/aquasecurity/trivy/releases/download/v${trivy_version}/trivy_${trivy_version}_Linux-64bit.tar.gz \
    && wget https://github.com/aquasecurity/trivy/releases/download/v${trivy_version}/trivy_${trivy_version}_checksums.txt \
    && grep "trivy_${trivy_version}_Linux-64bit.tar.gz" trivy_${trivy_version}_checksums.txt | sha256sum -c - \
    && tar -xzf trivy_${trivy_version}_Linux-64bit.tar.gz \
    && mv trivy /usr/local/bin/ \
    && rm -f *.tar.gz *.txt

COPY entrypoint.sh /usr/local/bin/entrypoint.sh
RUN chmod +x /usr/local/bin/entrypoint.sh

ENV HOME=/home/${non_root_user}
WORKDIR ${HOME}
RUN chown -R ${non_root_user}:${non_root_user} ${HOME}
USER ${non_root_user}
ENTRYPOINT ["trivy"]¨