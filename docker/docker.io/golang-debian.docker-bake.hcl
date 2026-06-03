variable "VEGITO_DOCKER_HUB_GOLANG_DEBIAN_IMAGE_LATEST" {
  default = "${VEGITO_PUBLIC_REPOSITORY}/golang-debian:latest"
}

variable "VEGITO_DOCKER_HUB_GOLANG_DEBIAN_IMAGE_VERSION" {
  default = "${VEGITO_PUBLIC_REPOSITORY}/golang-debian:${VERSION}"
}

target "docker-golang-debian-base" {
  context    = VEGITO_DOCKER_IO_HUB_DIR
  dockerfile = "golang-debian.Dockerfile"
  args = {
    debian_version = "bookworm"
    go_version     = GO_VERSION
  }
}

group "docker-golang-debian-ci" {
  targets = [
    "docker-golang-debian-version-ci",
    "docker-golang-debian-latest-ci",
  ]
}

target "docker-golang-debian-version-ci" {
  tags = [
    VEGITO_DOCKER_HUB_GOLANG_DEBIAN_IMAGE_VERSION,
  ]
  inherits  = ["docker-golang-debian-base"]
  platforms = platforms
}

target "docker-golang-debian-latest-ci" {
  tags = [
    VEGITO_DOCKER_HUB_GOLANG_DEBIAN_IMAGE_LATEST,
  ]
  inherits  = ["docker-golang-debian-base"]
  platforms = platforms
}

target "docker-golang-debian" {
  tags = [
    VEGITO_DOCKER_HUB_GOLANG_DEBIAN_IMAGE_VERSION,
    VEGITO_DOCKER_HUB_GOLANG_DEBIAN_IMAGE_LATEST,
  ]
  inherits = ["docker-golang-debian-base"]
}

variable "VEGITO_DOCKER_HUB_GOLANG_DEBIAN_TRIXIE_IMAGE_LATEST" {
  default = "${VEGITO_PUBLIC_REPOSITORY}/golang-debian-trixie:latest"
}

variable "VEGITO_DOCKER_HUB_GOLANG_DEBIAN_TRIXIE_IMAGE_VERSION" {
  default = "${VEGITO_PUBLIC_REPOSITORY}/golang-debian-trixie:${VERSION}"
}

target "docker-debian-trixie-golang-base" {
  context    = VEGITO_DOCKER_IO_HUB_DIR
  dockerfile = "golang-debian.Dockerfile"
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
    VEGITO_DOCKER_HUB_GOLANG_DEBIAN_TRIXIE_IMAGE_VERSION,
  ]
  inherits  = ["docker-debian-trixie-golang-base"]
  platforms = platforms
}

target "docker-debian-trixie-golang-latest-ci" {
  tags = [
    VEGITO_DOCKER_HUB_GOLANG_DEBIAN_TRIXIE_IMAGE_LATEST,
  ]
  inherits  = ["docker-debian-trixie-golang-base"]
  platforms = platforms
}

target "docker-debian-trixie-golang" {
  tags = [
    VEGITO_DOCKER_HUB_GOLANG_DEBIAN_TRIXIE_IMAGE_VERSION,
    VEGITO_DOCKER_HUB_GOLANG_DEBIAN_TRIXIE_IMAGE_LATEST,
  ]
  inherits = ["docker-debian-trixie-golang-base"]
}
