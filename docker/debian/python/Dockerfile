FROM debian

USER root

ARG TARGETPLATFORM

ARG debian_version=bookworm
RUN --mount=type=cache,id=vegito-debian-${debian_version}-${TARGETPLATFORM}-apt-cache,target=/var/cache/apt,sharing=locked \
    --mount=type=cache,id=vegito-debian-${debian_version}-${TARGETPLATFORM}-apt-lib,target=/var/lib/apt,sharing=locked \
    apt-get -o Acquire::Retries=3 update && apt-get install -y \
    adb \
    python3 python3-pip python3-venv

USER ${USER}

RUN python3 -m venv ${HOME}/venv

ENV PATH="${HOME}/venv/bin:$PATH"