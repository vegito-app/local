FROM debian

USER root

ARG TARGETPLATFORM

ARG debian_version=bookworm
RUN --mount=type=cache,id=vegito-debian-${debian_version}-${TARGETPLATFORM}-apt-cache,target=/var/cache/apt,sharing=locked \
    --mount=type=cache,id=vegito-debian-${debian_version}-${TARGETPLATFORM}-apt-lib,target=/var/lib/apt,sharing=locked \
    apt-get -o Acquire::Retries=3 update && apt-get install -y \
    adb 

ARG non_root_user=robot
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

WORKDIR ${HOME}

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

WORKDIR ${LOCAL_ROBOTFRAMEWORK_TESTS_DIR}

ENTRYPOINT [ "tests-entrypoint.sh" ]
CMD [ "robot" ]