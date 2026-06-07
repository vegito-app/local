FROM debian_project_builder

USER root


# GCP CLI

ARG non_root_user=github
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

WORKDIR /runner

ARG github_runner_version
ENV RUNNER_VERSION=${github_runner_version}

RUN curl -O -L https://github.com/actions/runner/releases/download/v$RUNNER_VERSION/actions-runner-linux-x64-$RUNNER_VERSION.tar.gz \
    && tar xzf ./actions-runner-linux-x64-$RUNNER_VERSION.tar.gz \
    && rm -f ./actions-runner-linux-x64-$RUNNER_VERSION.tar.gz \
    && ./bin/installdependencies.sh \
    && chown -R ${non_root_user}:${non_root_user} .

USER ${non_root_user}

ENV USER=${non_root_user}

ENV HOME=/home/debian

WORKDIR ${HOME}

ARG TARGETPLATFORM

RUN --mount=type=cache,id=local-github-actions-${TARGETPLATFORM}-npm-cache,target=${HOME}/.npm,sharing=locked,uid=${uid},gid=${gid} \
    --mount=type=cache,id=local-github-actions-${TARGETPLATFORM}-node-gyp,target=${HOME}/.cache/node-gyp,sharing=locked,uid=${uid},gid=${gid} \
    set -e ; \
    # 
    npm install -g \
    standard-version \
    conventional-changelog \
    conventional-changelog-angular

RUN firebase --version \
    && standard-version --version \
    && conventional-changelog --version \
    && npm --version

COPY entrypoint.sh /gha-entrypoint.sh
ENTRYPOINT ["/gha-entrypoint.sh"]

WORKDIR /runner/_work

ENV RUNNER_WORKDIR=/runner/_work
ENV RUNNER_BUILD_CACHE=/runner/_work/.containers
RUN mkdir ${RUNNER_BUILD_CACHE}
