FROM debian:bookworm

RUN apt-get update && apt-get install -y \
    curl \
    git \
    htop \
    make \
    rsync \
    socat \
    sudo \
    unzip \
    wget \
    xz-utils \
    # display
    x11vnc \
    xvfb \
    xinit openbox xorg \
    xdg-utils \
    menu-xdg \
    #Flutter
    clang \
    cmake \
    ninja-build \
    openjdk-17-jdk \
    libgtk-3-dev \
    # google-chrome-stable required:
    fonts-liberation \
    libvulkan1 \
    libpulse0 \
    libasound2 \
    && rm -rf /var/lib/apt/lists/*

ARG TARGETPLATFORM

# Install Google Chrome
RUN if [ "`dpkg --print-architecture`" = "amd64" ] && [ "`uname`" = "Linux" ]; then \
    curl -OL https://dl.google.com/linux/direct/google-chrome-stable_current_amd64.deb && \
    dpkg -i google-chrome-stable_current_amd64.deb && \
    rm -f google-chrome-stable_current_amd64.deb && \
    apt-get install -f -y ; \
    else \
    echo TARGETPLATFORM =  `dpkg --print-architecture` ; \
    echo "Chrome not supported on this platform "  ; \
    echo "Installing chromium"; \
    apt-get update && apt-get install -y chromium; \
    fi

RUN ln -sf /usr/bin/bash /bin/sh

ARG non_root_user=android

RUN useradd -m ${non_root_user} -u 1000 && echo "${non_root_user}:${non_root_user}" | chpasswd && adduser ${non_root_user} sudo \
    && echo "${non_root_user} ALL=(ALL) NOPASSWD:ALL" > /etc/sudoers.d/${non_root_user} \
    && chmod 0440 /etc/sudoers.d/${non_root_user} \
    \
    && chown -R ${non_root_user}:${non_root_user} ${HOME}

USER ${non_root_user}
ENV HOME=/home/${non_root_user}
WORKDIR ${HOME}

ENV ANDROID_SDK=${HOME}/Android/Sdk
ENV STUDIO_PATH=${HOME}/android-studio

ENV PATH=$PATH:$ANDROID_SDK/cmdline-tools/latest/bin
ENV PATH=$PATH:$ANDROID_SDK/emulator:$ANDROID_SDK/tools:$ANDROID_SDK/tools/bin:$ANDROID_SDK/platform-tools
ENV PATH=${STUDIO_PATH}/bin:${PATH}
ENV PATH=${PATH}:${HOME}/flutter/bin
ENV ANDROID_NDK_HOME=$ANDROID_SDK/ndk/27.0.12077973

ARG flutter_version=3.29.2
RUN \
    # Flutter 
    curl -o flutter.tar.xz -L https://storage.googleapis.com/flutter_infra_release/releases/stable/linux/flutter_linux_${flutter_version}-stable.tar.xz && \
    tar -xf flutter.tar.xz && rm flutter.tar.xz \
    # 
    # Android SDK
    && ANDROID_COMMANDLINETOOLS_URL=https://dl.google.com/android/repository/commandlinetools-linux-11076708_latest.zip; \
    mkdir -p $ANDROID_SDK/cmdline-tools/ && \
    cd $ANDROID_SDK/cmdline-tools/ && \
    curl -o sdk.zip -L $ANDROID_COMMANDLINETOOLS_URL && \
    unzip sdk.zip && \
    rm sdk.zip && \
    mv cmdline-tools latest && \
    yes | sdkmanager --licenses && \
    sdkmanager "platform-tools" "platforms;android-30" "emulator" "build-tools;30.0.1" "build-tools;35.0.0" "build-tools;36.0.0" "ndk;27.0.12077973"

ARG android_studio_version=2025.1.1.7
RUN ANDROID_STUDIO_URL=https://redirector.gvt1.com/edgedl/android/studio/ide-zips/${android_studio_version}/android-studio-${android_studio_version}-linux.tar.gz; \
    curl -o /tmp/android-studio.tar.gz -L $ANDROID_STUDIO_URL  && \
    tar -xzf /tmp/android-studio.tar.gz -C /tmp/ && \
    mv /tmp/android-studio ${STUDIO_PATH} && \
    rm /tmp/android-studio.tar.gz

RUN flutter doctor --android-licenses && flutter doctor

ENV DISPLAY=":1"
COPY display-start.sh /usr/local/bin/

COPY docker-caches-refresh.sh /usr/local/bin/studio-caches-refresh.sh
COPY entrypoint.sh /usr/local/bin/android-studio-entrypoint.sh

# Persist bash history for the non-root user
ENV HISTFILE=/home/${non_root_user}/.bash_history
RUN touch $HISTFILE && chown ${non_root_user}:${non_root_user} $HISTFILE
# Ensure history is written after each command in bash
RUN echo 'PROMPT_COMMAND="history -a; $PROMPT_COMMAND"' >> /home/${non_root_user}/.bashrc

ENTRYPOINT [ "android-studio-entrypoint.sh" ]
CMD ["studio"]
