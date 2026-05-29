ARG debian_version=bookworm
ARG go_version=latest
ARG TARGETPLATFORM
FROM golang:${go_version}-${debian_version}
