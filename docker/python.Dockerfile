FROM debian

RUN --mount=type=cache,id=local-robotframework-${TARGETPLATFORM}-apt-cache,target=/var/cache/apt,sharing=locked \
    --mount=type=cache,id=local-robotframework-${TARGETPLATFORM}-apt-lib,target=/var/lib/apt,sharing=locked \
    apt-get -o Acquire::Retries=3 update && apt-get install -y \
    adb \
    python3 python3-pip python3-venv