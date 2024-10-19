ARG builder_image=europe-west1-docker.pkg.dev/moov-438615/prod-docker-repository-public/moov-438615:builder-latest
FROM ${builder_image}

ENV RUNNER_VERSION=2.319.1
ENV RUNNER_WORKDIR=/runner/_work

USER root

WORKDIR /runner

ARG non_root_user=devuser

RUN chown -R ${non_root_user}:${non_root_user} /runner

RUN curl -O -L https://github.com/actions/runner/releases/download/v$RUNNER_VERSION/actions-runner-linux-x64-$RUNNER_VERSION.tar.gz \
    && tar xzf ./actions-runner-linux-x64-$RUNNER_VERSION.tar.gz \
    && rm -f ./actions-runner-linux-x64-$RUNNER_VERSION.tar.gz \
    && ./bin/installdependencies.sh

RUN npm install -g standard-version

COPY entrypoint.sh /entrypoint.sh

RUN chmod +x /entrypoint.sh

ENTRYPOINT ["/entrypoint.sh"]

RUN mkdir /runner/_work

VOLUME ["/runner/_work"]

USER ${non_root_user}