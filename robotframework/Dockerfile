FROM debian_image

RUN --mount=type=cache,id=local-robotframework-${TARGETPLATFORM}-apt-cache,target=/var/cache/apt,sharing=locked \
    --mount=type=cache,id=local-robotframework-${TARGETPLATFORM}-apt-lib,target=/var/lib/apt,sharing=locked \
    apt-get -o Acquire::Retries=3 update && apt-get install -y \
    adb \
    curl \
    htop \
    iftop \
    jq \
    make \
    netcat-openbsd \
    sudo \
    socat \
    tree \
    procps \
    python3 python3-pip python3-venv

ARG non_root_user=tests
ARG uid=1000
ARG gid=1000

ENV HOME=/home/${non_root_user}

RUN groupadd -g ${gid} ${non_root_user} \
    && useradd -m -u ${uid} -g ${gid} ${non_root_user} \
    && echo "${non_root_user}:${non_root_user}" | chpasswd && adduser ${non_root_user} sudo \
    && echo "${non_root_user} ALL=(ALL) NOPASSWD:ALL" > /etc/sudoers.d/${non_root_user} \
    && chmod 0440 /etc/sudoers.d/${non_root_user}

# Use Bash
RUN ln -sf /usr/bin/bash /bin/sh

# Prepare venv directory with proper permissions
RUN mkdir -p /opt/venv && chown ${uid}:${gid} /opt/venv

USER ${non_root_user}

RUN python3 -m venv ${HOME}/venv

ENV PATH="${HOME}/venv/bin:$PATH"

RUN --mount=type=cache,id=local-robotframework-${TARGETPLATFORM}-pip-cache,target=/home/${non_root_user}/.cache/pip,sharing=locked,uid=${uid},gid=${gid} \
    pip install \
    firebase-admin \
    robotframework \
    robotframework-appiumlibrary \
    robotframework-requests \
    robotframework-seleniumlibrary \
    robotframework-faker

COPY entrypoint.sh /usr/local/bin/tests-entrypoint.sh
COPY caches-refresh.sh /usr/local/bin/robotframework-caches-refresh.sh

ENV LOCAL_ROBOTFRAMEWORK_TESTS_DIR=${HOME}/robotframework

ENTRYPOINT [ "tests-entrypoint.sh" ]