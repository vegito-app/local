# Install Appium globally (requires Node.js)
FROM debian:bookworm

RUN apt-get update && apt-get install -y \
    bash-completion \
    curl \
    emacs-nox \
    git \
    htop \
    gnupg \
    jq \
    netcat-openbsd \
    make \
    rsync \
    socat \
    sudo \
    tree \
    unzip \
    vim \
    wget \
    xz-utils \
    # display
    x11vnc \
    xvfb \
    xinit openbox xorg \
    xdg-utils \
    menu-xdg \
    net-tools \
    xpra \
    #Flutter
    clang \
    cmake \
    # libxcb-cursor0 \
    ninja-build \
    openjdk-17-jdk \
    libgtk-3-dev \
    # google-chrome-stable required:
    fonts-liberation \
    libvulkan1 \
    libpulse0 \
    libasound2 \
    locales \
    && rm -rf /var/lib/apt/lists/* \
    &&  dpkg-reconfigure locales
    
RUN \
  export DEBIAN_FRONTEND=noninteractive ; \
  sed -i 's/Components: main/Components: main contrib non-free non-free-firmware/' /etc/apt/sources.list.d/debian.sources && \
    apt-get update && \
    apt-get install -y xserver-xorg-video-nvidia nvidia-driver mesa-utils

# Install Nodejs for Appium
RUN apt-get update && \
    curl -fsSL https://deb.nodesource.com/setup_18.x | bash - && \
    apt-get install -y nodejs

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

# Flutter 
ENV PATH=${PATH}:${HOME}/flutter/bin
ARG flutter_version
RUN git clone -b ${flutter_version} https://github.com/flutter/flutter.git && flutter doctor 

ENV FLUTTER=flutter

# Android SDK
ENV ANDROID_SDK=${HOME}/Android/Sdk
ENV PATH=${PATH}:${ANDROID_SDK}/cmdline-tools/latest/bin:${ANDROID_SDK}/emulator:${ANDROID_SDK}/tools:${ANDROID_SDK}/tools/bin:${ANDROID_SDK}/platform-tools
ENV ANDROID_HOME=${ANDROID_SDK}
ARG android_ndk_version
RUN ANDROID_COMMANDLINETOOLS_URL=https://dl.google.com/android/repository/commandlinetools-linux-13114758_latest.zip; \
    mkdir -p $ANDROID_SDK/cmdline-tools/ && \
    cd $ANDROID_SDK/cmdline-tools/ && \
    curl -o sdk.zip -L $ANDROID_COMMANDLINETOOLS_URL && \
    unzip sdk.zip && \
    rm sdk.zip && \
    mv cmdline-tools latest && \
    yes | sdkmanager --licenses && \
    sdkmanager \
    "platform-tools" \
    "platforms;android-34" \
    "sources;android-34" \
    "build-tools;34.0.0" \
    "ndk;${android_ndk_version}" \
    && case "$TARGETPLATFORM" in \
    "linux/amd64") \
    sudo npm install -g appium \
    && appium driver install uiautomator2 \
    && sdkmanager "emulator" \
    "system-images;android-34;google_apis_playstore;x86_64" \
    && echo "no" | avdmanager create avd -n Pixel_6_Playstore -k "system-images;android-34;google_apis_playstore;x86_64" -d "pixel_6" ;; \
    "linux/arm64") \
    echo "Skipping emulator install on $TARGETPLATFORM (not supported)" ;; \
    esac

ENV STUDIO_PATH=${HOME}/android-studio
ENV PATH=${STUDIO_PATH}/bin:${PATH}
ARG android_studio_version
RUN ANDROID_STUDIO_URL=https://redirector.gvt1.com/edgedl/android/studio/ide-zips/${android_studio_version}/android-studio-${android_studio_version}-linux.tar.gz; \
    curl -o /tmp/android-studio.tar.gz -L $ANDROID_STUDIO_URL  && \
    tar -xzf /tmp/android-studio.tar.gz -C /tmp/ && \
    mv /tmp/android-studio ${STUDIO_PATH} && \
    rm /tmp/android-studio.tar.gz

RUN flutter doctor --android-licenses && flutter doctor

ENV DISPLAY=":20"
COPY display-start.sh /usr/local/bin/
COPY display-start-xpra.sh /usr/local/bin/

COPY docker-caches-refresh.sh /usr/local/bin/studio-caches-refresh.sh
COPY entrypoint.sh /usr/local/bin/android-studio-entrypoint.sh
COPY appium-emulator-avd.sh /usr/local/bin/appium-emulator-avd.sh
COPY android-studio.sh /usr/local/bin/android-studio.sh
COPY emulator-data-load.sh /usr/local/bin/emulator-data-load.sh

# Persist bash history for the non-root user
ENV HISTFILE=/home/${non_root_user}/.bash_history
RUN touch $HISTFILE && chown ${non_root_user}:${non_root_user} $HISTFILE
# Ensure history is written after each command in bash
RUN echo 'PROMPT_COMMAND="history -a; $PROMPT_COMMAND"' >> /home/${non_root_user}/.bashrc

ENTRYPOINT [ "android-studio-entrypoint.sh" ]
CMD ["studio"]