FROM debian_image


RUN --mount=type=cache,id=local-robotframework-${TARGETPLATFORM}-apt-cache,target=/var/cache/apt,sharing=locked \
    --mount=type=cache,id=local-robotframework-${TARGETPLATFORM}-apt-lib,target=/var/lib/apt,sharing=locked \
    apt-get update && apt-get install -y \
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

RUN python3 -m venv /opt/venv

RUN --mount=type=cache,id=local-robotframework-${TARGETPLATFORM}-pip-cache,target=/home/${non_root_user}/.cache/pip,sharing=locked \
    /opt/venv/bin/pip install \
    firebase-admin \
    robotframework \
    robotframework-appiumlibrary \
    robotframework-requests \
    robotframework-seleniumlibrary \
    robotframework-faker

ENV PATH="/opt/venv/bin:$PATH"

ARG non_root_user=tests
ENV HOME=/home/${non_root_user}
WORKDIR ${HOME}

RUN useradd -m ${non_root_user} -u 1000 && echo "${non_root_user}:${non_root_user}" | chpasswd && adduser ${non_root_user} sudo \
    && echo "${non_root_user} ALL=(ALL) NOPASSWD:ALL" > /etc/sudoers.d/${non_root_user} \
    && chmod 0440 /etc/sudoers.d/${non_root_user} \
    \
    && chown -R ${non_root_user}:${non_root_user} ${HOME}

# Use Bash
RUN ln -sf /usr/bin/bash /bin/sh
USER ${non_root_user}
COPY entrypoint.sh /usr/local/bin/tests-entrypoint.sh
COPY caches-refresh.sh /usr/local/bin/robotframework-caches-refresh.sh

ENV LOCAL_ROBOTFRAMEWORK_TESTS_DIR=${HOME}/robotframework

ENTRYPOINT [ "tests-entrypoint.sh" ]