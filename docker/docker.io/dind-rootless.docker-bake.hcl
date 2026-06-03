
variable "VEGITO_DOCKER_HUB_DIND_ROOTLESS_IMAGE_LATEST" {
  default = "${VEGITO_PUBLIC_REPOSITORY}/docker-dind-rootless:latest"
}

variable "VEGITO_DOCKER_HUB_DIND_ROOTLESS_IMAGE_VERSION" {
  default = "${VEGITO_PUBLIC_REPOSITORY}/docker-dind-rootless:${VERSION}"
}

group "docker-dind-rootless-ci" {
  targets = [
    "docker-dind-rootless-version-ci",
    "docker-dind-rootless-latest-ci",
  ]
}

target "docker-dind-rootless-base" {
  context    = VEGITO_DOCKER_IO_HUB_DIR
  dockerfile = "dind-rootless.Dockerfile"
}

target "docker-dind-rootless-version-ci" {
  inherits = ["docker-dind-rootless-base"]
  tags = [
    VEGITO_DOCKER_HUB_DIND_ROOTLESS_IMAGE_VERSION,
  ]
  platforms = platforms
}

target "docker-dind-rootless-latest-ci" {
  tags = [
    VEGITO_DOCKER_HUB_DIND_ROOTLESS_IMAGE_LATEST,
  ]
  inherits  = ["docker-dind-rootless-base"]
  platforms = platforms
}

target "docker-dind-rootless" {
  tags = [
    VEGITO_DOCKER_HUB_DIND_ROOTLESS_IMAGE_VERSION,
    VEGITO_DOCKER_HUB_DIND_ROOTLESS_IMAGE_LATEST,
  ]
  inherits = ["docker-dind-rootless-base"]
}
