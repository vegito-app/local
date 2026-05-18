FROM desktop_x

USER root

ARG TARGETPLATFORM

RUN --mount=type=cache,id=local-nestor-${TARGETPLATFORM}-apt-cache,target=/var/cache/apt,sharing=locked \
    --mount=type=cache,id=local-nestor-${TARGETPLATFORM}-apt-lib,target=/var/lib/apt,sharing=locked \
    apt-get -o Acquire::Retries=3 update && apt-get install -y \
    python3 python3-pip python3-venv
# adb \


# ⚙️ IA Runtime
RUN --mount=type=cache,id=local-nestor-${TARGETPLATFORM}-apt-cache,target=/var/cache/apt,sharing=locked \
    --mount=type=cache,id=local-nestor-${TARGETPLATFORM}-apt-lib,target=/var/lib/apt,sharing=locked \
    pip install \
    openai \
    anthropic \
    transformers \
    accelerate \
    sentence-transformers \
    chromadb \
    llama-index \
    langchain

# Navigator runtime
RUN --mount=type=cache,id=local-nestor-${TARGETPLATFORM}-apt-cache,target=/var/cache/apt,sharing=locked \
    --mount=type=cache,id=local-nestor-${TARGETPLATFORM}-apt-lib,target=/var/lib/apt,sharing=locked \
    pip install \
    playwright && \
    playwright install --with-deps

# Runtime desktop automation
RUN --mount=type=cache,id=local-nestor-${TARGETPLATFORM}-apt-cache,target=/var/cache/apt,sharing=locked \
    --mount=type=cache,id=local-nestor-${TARGETPLATFORM}-apt-lib,target=/var/lib/apt,sharing=locked \
    apt-get install -y \
    xdotool \
    wmctrl \
    ydotool \
    grim \
    slurp \
    wl-clipboard

# Vision runtime
RUN --mount=type=cache,id=local-nestor-${TARGETPLATFORM}-apt-cache,target=/var/cache/apt,sharing=locked \
    --mount=type=cache,id=local-nestor-${TARGETPLATFORM}-apt-lib,target=/var/lib/apt,sharing=locked \
    apt-get install -y \
    python3-opencv \
    python3-numpy \
    python3-matplotlib \
    python3-scipy easyocr

RUN curl -fsSL https://ollama.com/install.sh | sh

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

COPY ./entrypoint.sh /usr/local/bin/nestor-entrypoint.sh
RUN chmod +x /usr/local/bin/nestor-entrypoint.sh 

COPY ./agent-start.sh /usr/local/bin/nestor-agent-start.sh
RUN chmod +x /usr/local/bin/nestor-agent-start.sh

ENTRYPOINT ["nestor-entrypoint.sh"]

CMD ["nestor-agent-start.sh"]