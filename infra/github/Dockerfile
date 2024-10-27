ARG builder_image=europe-west1-docker.pkg.dev/moov-438615/prod-docker-repository-public/moov-438615:builder-latest
FROM ${builder_image}

RUN npm install -g standard-version

ARG non_root_user=devuser
RUN sudo mkdir /runner \
    && sudo chown -R ${non_root_user}:${non_root_user} /runner

WORKDIR /runner

ENV RUNNER_VERSION=2.320.0

RUN curl -O -L https://github.com/actions/runner/releases/download/v$RUNNER_VERSION/actions-runner-linux-x64-$RUNNER_VERSION.tar.gz \
    && tar xzf ./actions-runner-linux-x64-$RUNNER_VERSION.tar.gz \
    && rm -f ./actions-runner-linux-x64-$RUNNER_VERSION.tar.gz \
    && sudo ./bin/installdependencies.sh

COPY entrypoint.sh /entrypoint.sh

ENTRYPOINT ["/entrypoint.sh"]


ARG non_root_user=devuser

USER ${non_root_user}

ENV RUNNER_WORKDIR=/runner/_work

RUN mkdir ${RUNNER_WORKDIR}

VOLUME ["${RUNNER_WORKDIR}"]
