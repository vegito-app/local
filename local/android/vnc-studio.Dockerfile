ARG builder_image=utrade-repository/utrade:builder
FROM --platform=${BUILDPLATFORM} ${builder_image}

USER root

# Install necessary software packages
RUN apt-get update && apt-get install -y \
    x11vnc \
    xvfb \
    wget \
    unzip

# Set environment variables for Android Studio
# ENV STUDIO_URL https://dl.google.com/dl/android/studio/ide-zips/3.5.3.0/android-studio-ide-191.6010548-linux.tar.gz
ENV STUDIO_URL=https://redirector.gvt1.com/edgedl/android/studio/ide-zips/2024.1.1.12/android-studio-2024.1.1.12-linux.tar.gz
ENV STUDIO_PATH=/opt/android-studio
ENV PATH=${STUDIO_PATH}/bin:${PATH}

# Download and unarchive Android Studio
RUN wget -q ${STUDIO_URL} -O /tmp/android-studio.tar.gz && \
    tar -xzf /tmp/android-studio.tar.gz -C /tmp/ && \
    mv /tmp/android-studio ${STUDIO_PATH} && \
    rm /tmp/android-studio.tar.gz

# Install necessary software packages
RUN apt-get update && apt-get install -y \
    xinit openbox xorg
# Start VNC server and Android studio

# RUN Xvfb :1 -screen 0 1024x768x24 &
ENV DISPLAY=:1

# Ajout du script de démarrage
COPY local/android/studio-start-docker.sh /opt/studio-start.sh
RUN chmod +x /opt/studio-start.sh

USER devuser    

# Configuré pour exécuter notre script au démarrage
CMD ["/opt/studio-start.sh"]

EXPOSE 5900
