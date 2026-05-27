variable "VEGITO_DOCKER_ALPINE_GOLANG_IMAGE_LATEST" {
  default = "${VEGITO_PUBLIC_REPOSITORY}/alpine-golang:latest"
}

variable "VEGITO_DOCKER_ALPINE_GOLANG_IMAGE_VERSION" {
  default = "${VEGITO_PUBLIC_REPOSITORY}/alpine-golang:${VERSION}"
}

target "docker-alpine-golang-base" {
  context    = VEGITO_DOCKER_IO_HUB_DIR
  dockerfile = "alpine-golang.Dockerfile"
}

group "docker-alpine-golang-ci" {
  targets = [
    "docker-alpine-golang-version-ci",
    "docker-alpine-golang-latest-ci",
  ]
}

target "docker-alpine-golang-version-ci" {

  tags = [
    VEGITO_DOCKER_ALPINE_GOLANG_IMAGE_VERSION,
  ]
  inherits  = ["docker-alpine-golang-base"]
  platforms = platforms
}

target "docker-alpine-golang-latest-ci" {
  tags = [
    VEGITO_DOCKER_ALPINE_GOLANG_IMAGE_LATEST,
  ]
  inherits  = ["docker-alpine-golang-base"]
  platforms = platforms
}

target "docker-alpine-golang" {
  tags = [
    VEGITO_DOCKER_ALPINE_GOLANG_IMAGE_VERSION,
    VEGITO_DOCKER_ALPINE_GOLANG_IMAGE_LATEST,
  ]
  inherits = ["docker-alpine-golang-base"]
}
