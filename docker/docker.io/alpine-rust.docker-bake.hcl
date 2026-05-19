variable "VEGITO_DOCKER_ALPINE_RUST_IMAGE_LATEST" {
  default = "${VEGITO_PUBLIC_REPOSITORY}/alpine-rust:latest"
}

variable "VEGITO_DOCKER_ALPINE_RUST_IMAGE_VERSION" {
  default = "${VEGITO_PUBLIC_REPOSITORY}/alpine-rust:${VERSION}"
}

target "docker-alpine-rust-base" {
  context    = VEGITO_DOCKER_IO_HUB_DIR
  dockerfile = "alpine-rust.Dockerfile"
}

group "docker-alpine-rust-ci" {
  targets = [
    "docker-alpine-rust-version-ci",
    "docker-alpine-rust-latest-ci",
  ]
}

target "docker-alpine-rust-version-ci" {

  tags = [
    VEGITO_DOCKER_ALPINE_RUST_IMAGE_VERSION,
  ]
  inherits  = ["docker-alpine-rust-base"]
  platforms = platforms
}

target "docker-alpine-rust-latest-ci" {
  tags = [
    VEGITO_DOCKER_ALPINE_RUST_IMAGE_LATEST,
  ]
  inherits  = ["docker-alpine-rust-base"]
  platforms = platforms
}

target "docker-alpine-rust" {
  tags = [
    VEGITO_DOCKER_ALPINE_RUST_IMAGE_VERSION,
    VEGITO_DOCKER_ALPINE_RUST_IMAGE_LATEST,
  ]
  inherits = ["docker-alpine-rust-base"]
}
