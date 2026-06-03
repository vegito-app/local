ARG debian_version=bookworm
FROM debian:${debian_version}-slim
ARG debian_version=bookworm
ENV DEBIAN_VERSION=${debian_version}