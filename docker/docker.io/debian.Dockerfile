ARG debian_version=bookworm-slim
FROM debian:${debian_version}
ENV DEBIAN_VERSION=${debian_version}