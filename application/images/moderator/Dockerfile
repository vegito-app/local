# application/moderator/Dockerfile
ARG builder_image=europe-west1-docker.pkg.dev/moov-dev-439608/docker-repository-public/moov-dev-439608:builder-latest
FROM ${builder_image} AS build
WORKDIR /app
COPY application/images .
RUN go mod download
RUN go mod verify
RUN go build -o moderator moderator/moderator.go
# Use a minimal base image for the final build
FROM debian:bookworm-slim
COPY --from=build /app/moderator /usr/bin/application-images-moderator
ENTRYPOINT ["/usr/bin/application-images-moderator"]