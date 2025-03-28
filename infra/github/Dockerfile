ARG builder_image=europe-west1-docker.pkg.dev/moov-dev-439608/docker-repository-public/moov-dev-439608:builder-latest
FROM ${builder_image}

USER root
RUN npm install -g standard-version
RUN mkdir /runner
WORKDIR /runner
ENV RUNNER_VERSION=2.320.0
ARG non_root_user=devuser
RUN curl -O -L https://github.com/actions/runner/releases/download/v$RUNNER_VERSION/actions-runner-linux-x64-$RUNNER_VERSION.tar.gz \
    && tar xzf ./actions-runner-linux-x64-$RUNNER_VERSION.tar.gz \
    && rm -f ./actions-runner-linux-x64-$RUNNER_VERSION.tar.gz \
    && ./bin/installdependencies.sh \
    && chown -R ${non_root_user}:${non_root_user} .
COPY entrypoint.sh /entrypoint.sh
ENTRYPOINT ["/entrypoint.sh"]
USER ${non_root_user}
ENV RUNNER_WORKDIR=/runner/_work
RUN mkdir ${RUNNER_WORKDIR}
VOLUME ["${RUNNER_WORKDIR}"]
