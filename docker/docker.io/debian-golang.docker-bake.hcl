variable "VEGITO_DOCKER_DEBIAN_GOLANG_IMAGE_LATEST" {
  default = "${VEGITO_PUBLIC_REPOSITORY}/debian-golang:latest"
}

variable "VEGITO_DOCKER_DEBIAN_GOLANG_IMAGE_VERSION" {
  default = "${VEGITO_PUBLIC_REPOSITORY}/debian-golang:${VERSION}"
}

target "docker-debian-golang-base" {
  context    = VEGITO_DOCKER_IO_HUB_DIR
  dockerfile = "debian-golang.Dockerfile"
  args = {
    debian_version = "bookworm"
    go_version     = GO_VERSION
  }
}

group "docker-debian-golang-ci" {
  targets = [
    "docker-debian-golang-version-ci",
    "docker-debian-golang-latest-ci",
  ]
}

target "docker-debian-golang-version-ci" {

  tags = [
    VEGITO_DOCKER_DEBIAN_GOLANG_IMAGE_VERSION,
  ]
  inherits  = ["docker-debian-golang-base"]
  platforms = platforms
}

target "docker-debian-golang-latest-ci" {
  tags = [
    VEGITO_DOCKER_DEBIAN_GOLANG_IMAGE_LATEST,
  ]
  inherits  = ["docker-debian-golang-base"]
  platforms = platforms
}

target "docker-debian-golang" {
  tags = [
    VEGITO_DOCKER_DEBIAN_GOLANG_IMAGE_VERSION,
    VEGITO_DOCKER_DEBIAN_GOLANG_IMAGE_LATEST,
  ]
  inherits = ["docker-debian-golang-base"]
}

variable "VEGITO_DOCKER_DEBIAN_TRIXIE_GOLANG_IMAGE_LATEST" {
  default = "${VEGITO_PUBLIC_REPOSITORY}/debian-trixie-golang:latest"
}

variable "VEGITO_DOCKER_DEBIAN_TRIXIE_GOLANG_IMAGE_VERSION" {
  default = "${VEGITO_PUBLIC_REPOSITORY}/debian-trixie-golang:${VERSION}"
}

target "docker-debian-trixie-golang-base" {
  context    = VEGITO_DOCKER_IO_HUB_DIR
  dockerfile = "debian-golang.Dockerfile"
  args = {
    debian_version = "trixie"
    go_version     = GO_VERSION
  }
}

group "docker-debian-trixie-golang-ci" {
  targets = [
    "docker-debian-trixie-golang-version-ci",
    "docker-debian-trixie-golang-latest-ci",
  ]
}

target "docker-debian-trixie-golang-version-ci" {

  tags = [
    VEGITO_DOCKER_DEBIAN_TRIXIE_GOLANG_IMAGE_VERSION,
  ]
  inherits  = ["docker-debian-trixie-golang-base"]
  platforms = platforms
}

target "docker-debian-trixie-golang-latest-ci" {
  tags = [
    VEGITO_DOCKER_DEBIAN_TRIXIE_GOLANG_IMAGE_LATEST,
  ]
  inherits  = ["docker-debian-trixie-golang-base"]
  platforms = platforms
}

target "docker-debian-trixie-golang" {
  tags = [
    VEGITO_DOCKER_DEBIAN_TRIXIE_GOLANG_IMAGE_VERSION,
    VEGITO_DOCKER_DEBIAN_TRIXIE_GOLANG_IMAGE_LATEST,
  ]
  inherits = ["docker-debian-trixie-golang-base"]
}
