ARG builder_image=docker-repository-public/utrade:builder-latest
FROM ${builder_image}

ENV RUNNER_VERSION=2.319.1
ENV RUNNER_WORKDIR=/runner/_work

WORKDIR /runner
RUN sudo chown -R ${USER}:${USER} /runner

RUN curl -O -L https://github.com/actions/runner/releases/download/v$RUNNER_VERSION/actions-runner-linux-x64-$RUNNER_VERSION.tar.gz \
    && tar xzf ./actions-runner-linux-x64-$RUNNER_VERSION.tar.gz \
    && rm -f ./actions-runner-linux-x64-$RUNNER_VERSION.tar.gz \
    && sudo ./bin/installdependencies.sh

COPY entrypoint.sh /entrypoint.sh

RUN sudo chmod +x /entrypoint.sh

ENTRYPOINT ["/entrypoint.sh"]

RUN mkdir /runner/_work

VOLUME ["/runner/_work"]
