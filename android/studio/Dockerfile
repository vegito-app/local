FROM android

USER root

# Make /bin/sh point to bash (and not dash)
RUN ln -sf /usr/bin/bash /bin/sh

ARG non_root_user=android-studio
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

ENV USER=${non_root_user}

USER ${non_root_user}

WORKDIR ${HOME}

# Android SDK complete (NDK + build-tools)
ENV ANDROID_SDK=${HOME}/Android/Sdk
ENV PATH=${PATH}:${ANDROID_SDK}/cmdline-tools/latest/bin:${ANDROID_SDK}/platform-tools:${ANDROID_SDK}/build-tools/34.0.0
ARG android_ndk_version
RUN sdkmanager \
  "build-tools;34.0.0" \
  "platforms;android-34" \
  "platforms;android-36" \
  "ndk;${android_ndk_version}"

ENV PATH=${HOME}/node_modules/.bin:${PATH}

# Android Studio
ENV STUDIO_PATH=${HOME}/android-studio
ENV PATH=${STUDIO_PATH}/bin:${PATH}
ARG android_studio_version
# RUN curl -o /tmp/android-studio.tar.gz -L "https://redirector.gvt1.com/edgedl/android/studio/ide-zips/${android_studio_version}/android-studio-${android_studio_version}-linux.tar.gz" && \
RUN curl -o /tmp/android-studio.tar.gz -L https://edgedl.me.gvt1.com/android/studio/ide-zips/${android_studio_version}-linux.tar.gz && \
  tar -xzf /tmp/android-studio.tar.gz -C /tmp/ && \
  mv /tmp/android-studio ${STUDIO_PATH} && rm /tmp/android-studio.tar.gz

RUN flutter doctor --android-licenses && flutter doctor

# Entrypoints & scripts
COPY --chown=${non_root_user}:${non_root_user} container-install.sh /usr/local/bin/android-studio-container-install.sh
COPY --chown=${non_root_user}:${non_root_user} container-start.sh /usr/local/bin/android-studio-container-start.sh
COPY --chown=${non_root_user}:${non_root_user} container-entrypoint.sh /usr/local/bin/android-studio-entrypoint.sh

COPY android-studio.desktop /usr/share/applications/

ENTRYPOINT ["android-studio-entrypoint.sh"]
CMD ["android-studio-container-start.sh"]

