ARG builder_image=europe-west1-docker.pkg.dev/moov-438615/docker-repository-public/moov-438615:builder
FROM ${builder_image}

USER root

RUN apt-get update && apt-get install -y \
    x11vnc \
    xvfb \
    xinit openbox xorg \
    xdg-utils \
    #Flutter
    clang \
    cmake \
    ninja-build \
    libgtk-3-dev \
    # google-chrome-stable required:
    fonts-liberation \
    libvulkan1 \
    libpulse0 \
    && rm -rf /var/lib/apt/lists/*

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

COPY studio-entrypoint.sh /usr/local/bin/android-studio-docker-entrypoint.sh

COPY caches-refresh.sh /usr/local/bin/local-android-caches-refresh.sh

# X11
ENV DISPLAY=":1"
COPY display-start.sh /usr/local/bin/

ARG non_root_user=devuser

USER ${non_root_user}

ENV HOME=/home/${non_root_user}
WORKDIR ${HOME}/

ENV ANDROID_SDK=${HOME}/Android/Sdk
ENV STUDIO_PATH=${HOME}/android-studio

ENV PATH=$PATH:$ANDROID_SDK/cmdline-tools/latest/bin
ENV PATH=$PATH:$ANDROID_SDK/emulator:$ANDROID_SDK/tools:$ANDROID_SDK/tools/bin:$ANDROID_SDK/platform-tools
ENV PATH=${STUDIO_PATH}/bin:${PATH}
ENV PATH=${PATH}:${HOME}/flutter/bin

ARG flutter_version=3.29.2
ARG android_studio_version=2024.3.1.13

RUN \
    # Flutter 
    curl -o flutter.tar.xz -L https://storage.googleapis.com/flutter_infra_release/releases/stable/linux/flutter_linux_${flutter_version}-stable.tar.xz && \
    tar -xf flutter.tar.xz -C ${HOME}/ && rm flutter.tar.xz \
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
    sdkmanager "platform-tools" "platforms;android-30" \
    && ANDROID_STUDIO_URL=https://redirector.gvt1.com/edgedl/android/studio/ide-zips/${android_studio_version}/android-studio-${android_studio_version}-linux.tar.gz; \
    curl -o /tmp/android-studio.tar.gz -L $ANDROID_STUDIO_URL  && \
    tar -xzf /tmp/android-studio.tar.gz -C /tmp/ && \
    mv /tmp/android-studio ${STUDIO_PATH} && \
    rm /tmp/android-studio.tar.gz \
    && if [ "`dpkg --print-architecture`" = "amd64" ] && [ "`uname`" = "Linux" ]; then \
    sdkmanager "build-tools;30.0.1" "build-tools;35.0.0" "emulator" && \
    # Telemetry is not sent on the very first run. To disable reporting of telemetry,
    # run this terminal command:
    flutter && \
    # Accept All Androïd SDK package licenses
    flutter doctor --android-licenses ; \
    fi \
    && chown -R ${non_root_user}:${non_root_user} ${HOME}/.config

ENTRYPOINT [ "android-studio-docker-entrypoint.sh" ]
CMD ["studio.sh"]
EXPOSE 5900
