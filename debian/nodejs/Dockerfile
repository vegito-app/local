FROM debian
ARG debian_version=bookworm
ARG TARGETPLATFORM

USER root

ARG non_root_user=nodejs
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

USER ${non_root_user}    

ENV USER=${non_root_user}

WORKDIR ${HOME}

ENV PATH=${PATH}:${HOME}/go/bin

ENV NVM_DIR=${HOME}/nvm

ARG nvm_version
ARG node_version
RUN --mount=type=cache,id=local-builder-${debian_version}-${TARGETPLATFORM}-npm-cache,target=${HOME}/.npm,sharing=locked,uid=${uid},gid=${gid} \
    --mount=type=cache,id=local-builder-${debian_version}-${TARGETPLATFORM}-node-gyp,target=${HOME}/.cache/node-gyp,sharing=locked,uid=${uid},gid=${gid} \
    set -e ; \
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
    depcheck \
    firebase-tools \
    npm-check-updates \
    npm-check \
    npm
# firebase-tools \
# @devcontainers/cli

ENV NODE_PATH=$NVM_DIR/versions/node/v${node_version}/lib/node_modules
ENV PATH=$NVM_DIR/versions/node/v${node_version}/bin:$PATH

ENV PATH=${HOME}/bin:$PATH