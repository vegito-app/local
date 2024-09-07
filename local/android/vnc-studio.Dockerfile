ARG builder_image=utrade-repository/utrade:builder
FROM --platform=${BUILDPLATFORM} ${builder_image}

# Set environment variables for Android Studio
ENV STUDIO_URL=https://redirector.gvt1.com/edgedl/android/studio/ide-zips/2024.1.1.12/android-studio-2024.1.1.12-linux.tar.gz
ENV STUDIO_PATH=${HOME}/android-studio
ENV PATH=${STUDIO_PATH}/bin:${PATH}

# Download and unarchive Android Studio
RUN curl -o /tmp/android-studio.tar.gz -L ${STUDIO_URL} && \
    tar -xzf /tmp/android-studio.tar.gz -C /tmp/ && \
    mv /tmp/android-studio ${STUDIO_PATH} && \
    rm /tmp/android-studio.tar.gz

# Ajout du script de démarrage
COPY local/android/studio-entrypoint.sh ${STUDIO_PATH}/bin/studio-docker-entrypoint.sh

# Configuré pour exécuter notre script au démarrage
ENTRYPOINT [ "studio-docker-entrypoint.sh" ]
CMD ["studio.sh"]
EXPOSE 5900