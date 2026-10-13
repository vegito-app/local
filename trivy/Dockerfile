FROM debian

USER root

# Install Trivy
ARG trivy_version

RUN wget https://github.com/aquasecurity/trivy/releases/download/v${trivy_version}/trivy_${trivy_version}_Linux-64bit.tar.gz \
    && wget https://github.com/aquasecurity/trivy/releases/download/v${trivy_version}/trivy_${trivy_version}_checksums.txt \
    && grep "trivy_${trivy_version}_Linux-64bit.tar.gz" trivy_${trivy_version}_checksums.txt | sha256sum -c - \
    && tar -xzf trivy_${trivy_version}_Linux-64bit.tar.gz \
    && mv trivy /usr/local/bin/ \
    && rm -f *.tar.gz *.txt

ARG non_root_user=trivy
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

ENV USER=${non_root_user}
USER ${non_root_user}
WORKDIR ${HOME}


USER ${non_root_user}

ENV HOME=/home/${non_root_user}
WORKDIR ${HOME}

COPY container-install.sh /usr/local/bin/trivy-container-install.sh
COPY entrypoint.sh /usr/local/bin/trivy-entrypoint.sh
ENTRYPOINT ["trivy-entrypoint.sh"]