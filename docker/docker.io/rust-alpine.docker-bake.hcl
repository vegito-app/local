variable "VEGITO_DOCKER_ALPINE_RUST_IMAGE_LATEST" {
  default = "${VEGITO_PUBLIC_REPOSITORY}/rust-alpine:latest"
}

variable "VEGITO_DOCKER_ALPINE_RUST_IMAGE_VERSION" {
  default = "${VEGITO_PUBLIC_REPOSITORY}/rust-alpine:${VERSION}"
}

target "docker-rust-alpine-base" {
  context    = VEGITO_DOCKER_IO_HUB_DIR
  dockerfile = "rust-alpine.Dockerfile"
}

group "docker-rust-alpine-ci" {
  targets = [
    "docker-rust-alpine-version-ci",
    "docker-rust-alpine-latest-ci",
  ]
}

target "docker-rust-alpine-version-ci" {

  tags = [
    VEGITO_DOCKER_ALPINE_RUST_IMAGE_VERSION,
  ]
  inherits  = ["docker-rust-alpine-base"]
  platforms = platforms
}

target "docker-rust-alpine-latest-ci" {
  tags = [
    VEGITO_DOCKER_ALPINE_RUST_IMAGE_LATEST,
  ]
  inherits  = ["docker-rust-alpine-base"]
  platforms = platforms
}

target "docker-rust-alpine" {
  tags = [
    VEGITO_DOCKER_ALPINE_RUST_IMAGE_VERSION,
    VEGITO_DOCKER_ALPINE_RUST_IMAGE_LATEST,
  ]
  inherits = ["docker-rust-alpine-base"]
}
