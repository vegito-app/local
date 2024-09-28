# Build the React App
ARG builder_image=docker-repository-public/utrade:builder
FROM ${builder_image}

# Variables d'environnement pour le runner
ENV RUNNER_VERSION=2.319.1
ENV RUNNER_WORKDIR=/runner/_work

WORKDIR /runner

# Télécharger et installer le GitHub Actions Runner
RUN curl -O -L https://github.com/actions/runner/releases/download/v$RUNNER_VERSION/actions-runner-linux-x64-$RUNNER_VERSION.tar.gz \
    && tar xzf ./actions-runner-linux-x64-$RUNNER_VERSION.tar.gz \
    && rm -f ./actions-runner-linux-x64-$RUNNER_VERSION.tar.gz \
    && sudo ./bin/installdependencies.sh

# Configurer les permissions
RUN mkdir -p /runner/_work && sudo chown -R $USER:$USER /runner

# Exposer le dossier de travail
VOLUME ["/runner/_work"]

# Entrée du container - pour démarrer le runner
CMD ["./config.sh"]