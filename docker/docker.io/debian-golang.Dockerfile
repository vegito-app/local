ARG debian_version=bookworm
ARG go_version=latest
ARG TARGETPLATFORM
FROM --platform=${TARGETPLATFORM} golang:${go_version}-${debian_version}
