ARG local_dev_docker_registry=europe-west1-docker.pkg.dev/moov-dev-439608
ARG debian_image=debian:latest
ARG builder_image=${local_dev_docker_registry}/docker-repository-public/vegito-local:builder-latest

FROM ${builder_image} AS builder
FROM ${debian_image}

COPY --from=builder /usr/local/bin/localproxy /usr/local/bin/localproxy

RUN apt-get update && apt-get install -y \
    apt-transport-https \
    ca-certificates \
    gnupg \
    curl \
    htop \
    jq \
    make \
    netcat-openbsd \
    sudo \
    && rm -rf /var/lib/apt/lists/*

# Install Temurin 21 (Adoptium) - reliable way to get Java 21 on Debian
RUN set -eu; \
    # Try to use Adoptium apt repo for this distro; fallback to tarball install if repo not available
    DIST_CODENAME="$(. /etc/os-release && echo "$VERSION_CODENAME")"; \
    ADOPTIUM_OK=0; \
    for codename in "$DIST_CODENAME" stable bookworm bullseye; do \
    if curl -fsS "https://packages.adoptium.net/artifactory/deb/dists/${codename}/Release" >/dev/null 2>&1; then \
    curl -fsSL https://packages.adoptium.net/artifactory/api/gpg/key/public | gpg --dearmor -o /usr/share/keyrings/adoptium-archive-keyring.gpg; \
    echo "deb [signed-by=/usr/share/keyrings/adoptium-archive-keyring.gpg] https://packages.adoptium.net/artifactory/deb ${codename} main" > /etc/apt/sources.list.d/adoptium.list; \
    apt-get update; apt-get install -y temurin-21-jdk && ADOPTIUM_OK=1 && break; \
    fi; \
    done; \
    if [ "$ADOPTIUM_OK" -ne 1 ]; then \
    echo "Adoptium apt repo not available for this distro, downloading Temurin 21 tarball..."; \
    TMPDIR="/tmp/temurin21"; mkdir -p "$TMPDIR"; \
    curl -fsSL -o /tmp/temurin21.tar.gz "https://github.com/adoptium/temurin21-binaries/releases/latest/download/OpenJDK21U-jdk_x64_linux_hotspot.tar.gz"; \
    tar -xzf /tmp/temurin21.tar.gz -C /tmp; \
    JB_DIR=$(find /tmp -maxdepth 1 -type d -name 'jdk*' -print -quit); \
    mkdir -p /usr/lib/jvm; \
    mv "$JB_DIR" /usr/lib/jvm/temurin-21; \
    update-alternatives --install /usr/bin/java java /usr/lib/jvm/temurin-21/bin/java 1; \
    update-alternatives --install /usr/bin/javac javac /usr/lib/jvm/temurin-21/bin/javac 1; \
    fi; \
    apt-get clean; rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*

ARG non_root_user=firebase

RUN useradd -m ${non_root_user} -u 1000 && echo "${non_root_user}:${non_root_user}" | chpasswd && adduser ${non_root_user} sudo \
    && echo "${non_root_user} ALL=(ALL) NOPASSWD:ALL" > /etc/sudoers.d/${non_root_user} \
    && chmod 0440 /etc/sudoers.d/${non_root_user} \
    \
    && chown -R ${non_root_user}:${non_root_user} ${HOME}

ENV HOME=/home/${non_root_user}
WORKDIR ${HOME}

USER ${non_root_user}

ENV NVM_DIR=${HOME}/nvm

ARG nvm_version=0.40.1
ARG node_version=22.14.0
RUN set -e ; \
    # 
    mkdir -p ${NVM_DIR} ; \
    #
    curl -o- https://raw.githubusercontent.com/nvm-sh/nvm/v${nvm_version}/install.sh | bash - ; \
    . ${NVM_DIR}/nvm.sh ; \
    nvm install ${node_version} ; \
    nvm alias default ${node_version} ; \
    nvm use default ;  \
    # 
    npm install -g \
    firebase-tools \
    depcheck \
    npm-check-updates \
    npm-check \
    npm ; \
    rm -rf ${HOME}/.npm 


ENV NODE_PATH=$NVM_DIR/versions/node/v${node_version}/lib/node_modules
ENV PATH=$NVM_DIR/versions/node/v${node_version}/bin:$PATH

RUN for svc in firestore database pubsub storage ui ; do \
    firebase --version && firebase setup:emulators:$svc ; \
    done

COPY container-refresh-caches.sh /usr/local/bin/firebase-emulators-refresh-caches.sh
COPY entrypoint.sh /usr/local/bin/firebase-emulators-entrypoint.sh
COPY firebase-emulators-config-create-json.sh /usr/local/bin/firebase-emulators-config-create-json.sh

USER root
RUN ln -sf /usr/bin/bash /bin/sh

USER ${non_root_user}
ENTRYPOINT [ "firebase-emulators-entrypoint.sh" ]

COPY emulators-run.sh /usr/local/bin/firebase-emulators-run.sh
CMD [ "firebase-emulators-run.sh" ]