ARG debian_version=bookworm
FROM debian:${debian_version}-slim
ENV DEBIAN_VERSION=${debian_version}