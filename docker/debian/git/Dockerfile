FROM debian

USER root

ARG TARGETPLATFORM

ARG debian_version=bookworm
RUN --mount=type=cache,id=vegito-debian-${debian_version}-${TARGETPLATFORM}-apt-cache,target=/var/cache/apt,sharing=locked \
    --mount=type=cache,id=vegito-debian-${debian_version}-${TARGETPLATFORM}-apt-lib,target=/var/lib/apt,sharing=locked \
    python3 python3-pip python3-venv

ARG gitleaks_version=8.28.0

RUN case "$TARGETPLATFORM" in "linux/amd64") \
    url="https://github.com/gitleaks/gitleaks/releases/download/v${gitleaks_version}/gitleaks_${gitleaks_version}_linux_x64.tar.gz" ; \
    ;; \
    "linux/arm64") \
    url="https://github.com/gitleaks/gitleaks/releases/download/v${gitleaks_version}/gitleaks_${gitleaks_version}_linux_arm64.tar.gz" ; \
    ;; \
    *) echo >&2 "warning: unsupported 'gitleaks' architecture ($TARGETPLATFORM); skipping"; exit 0 ;; \
    esac; \
    echo "Downloading gitleaks from $url"; \
    curl -L -o /tmp/gitleaks.tar.gz $url \
    && mkdir -p /tmp/gitleaks \
    && tar -xvzf /tmp/gitleaks.tar.gz -C /tmp/gitleaks \
    && mv /tmp/gitleaks/gitleaks /usr/local/bin/gitleaks \
    && rm -rf /tmp/gitleaks \
    && gitleaks version

USER ${USER}

RUN python3 -m venv ${HOME}/venv

ENV PATH="${HOME}/venv/bin:$PATH"