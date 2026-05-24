
FROM debian

ARG TARGETPLATFORM

USER root

ARG debian_version=bookworm

# Vision runtime
RUN --mount=type=cache,id=vegito-debian-${debian_version}-${TARGETPLATFORM}-apt-cache,target=/var/cache/apt,sharing=locked \
    --mount=type=cache,id=vegito-debian-${debian_version}-${TARGETPLATFORM}-apt-lib,target=/var/lib/apt,sharing=locked \
    apt-get update && \
    apt-get install -y \
    python3-opencv \
    python3-numpy \
    python3-matplotlib \
    python3-scipy \
    tesseract-ocr \
    zstd

RUN curl -fsSL https://ollama.com/install.sh | sh

# Runtime desktop automation
RUN --mount=type=cache,id=vegito-debian-${debian_version}-${TARGETPLATFORM}-apt-cache,target=/var/cache/apt,sharing=locked \
    --mount=type=cache,id=vegito-debian-${debian_version}-${TARGETPLATFORM}-apt-lib,target=/var/lib/apt,sharing=locked \
    apt-get install -y \
    xdotool \
    wmctrl 
# ydotool \
# grim \
# slurp \
# wl-clipboard

RUN mkdir -p /etc/apt/keyrings && \
    curl -fsSL https://packages.microsoft.com/keys/microsoft.asc \
    | gpg --dearmor \
    > /etc/apt/keyrings/packages.microsoft.gpg && \
    chmod go+r /etc/apt/keyrings/packages.microsoft.gpg && \
    echo "deb [arch=amd64 signed-by=/etc/apt/keyrings/packages.microsoft.gpg] https://packages.microsoft.com/repos/code stable main" \
    > /etc/apt/sources.list.d/vscode.list && \
    apt-get update && \
    apt-get install -y code

# 👤 Create non root user
ARG non_root_user=nestor
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

# 👤 Switch to non root user
USER ${non_root_user}

ARG uid=1000
ARG gid=1000
RUN --mount=type=cache,id=vegito-debian-${debian_version}-${TARGETPLATFORM}-python-build,target=/home/debian/.cache,sharing=locked,uid=${uid},gid=${gid} \
    pip install --upgrade pip setuptools wheel

RUN --mount=type=cache,id=vegito-debian-${debian_version}-${TARGETPLATFORM}-python-build,target=/home/debian/.cache,sharing=locked,uid=${uid},gid=${gid} \
    pip install \
    easyocr \
    openai \
    anthropic \
    transformers \
    accelerate \
    sentence-transformers \
    chromadb \
    llama-index \
    langchain

# Navigator runtime
RUN --mount=type=cache,id=vegito-debian-${debian_version}-${TARGETPLATFORM}-python-build,target=/home/debian/.cache,sharing=locked,uid=${uid},gid=${gid} \
    pip install \
    playwright && \
    playwright install --with-deps

# Navigator runtime
RUN --mount=type=cache,id=vegito-debian-${debian_version}-${TARGETPLATFORM}-python-build,target=/home/debian/.cache,sharing=locked,uid=${uid},gid=${gid} \
    pip install \
    torch \
    torchvision \
    torchaudio

COPY --chown=${uid}:${gid} ./entrypoint.sh /usr/local/bin/ai-entrypoint.sh
RUN chmod +x /usr/local/bin/ai-entrypoint.sh 

COPY --chown=${uid}:${gid} ./runtime-start.sh /usr/local/bin/ai-runtime-start.sh
RUN chmod +x /usr/local/bin/ai-runtime-start.sh

COPY --chown=${uid}:${gid} ./container-install.sh /usr/local/bin/ai-container-install.sh
RUN chmod +x /usr/local/bin/ai-container-install.sh

COPY --chown=${uid}:${gid} ./container-healthcheck.sh /usr/local/bin/ai-container-healthcheck.sh
RUN chmod +x /usr/local/bin/ai-container-healthcheck.sh

ENTRYPOINT ["tini", "--", "ai-entrypoint.sh"]
CMD ["ai-runtime-start.sh"]

RUN mkdir -p /home/debian/.ollama/models && \
    chmod -R 700 /home/debian/.ollama/models && \
    mkdir -p /home/debian/.ollama/cache && \
    chmod -R 700 /home/debian/.ollama/cache && \
    mkdir -p /home/debian/.cache/huggingface && \
    chmod -R 700 /home/debian/.cache/huggingface && \
    mkdir -p /home/debian/.cache/torch && \
    chmod -R 700 /home/debian/.cache/torch && \
    mkdir -p /home/debian/.cache/torch_extensions && \
    chmod -R 700 /home/debian/.cache/torch_extensions

HEALTHCHECK CMD test -f /tmp/.ai-runtime-ready|| exit 1
