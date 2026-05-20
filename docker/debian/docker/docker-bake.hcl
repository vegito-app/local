variable "VEGITO_DOCKER_DEBIAN_DOCKER_DIR" {
  default = "${VEGITO_DOCKER_DEBIAN_DIR}/docker"
}

target "vegito-debian-docker-base" {
  args = {
    docker_buildx_version  = DOCKER_BUILDX_VERSION
    docker_compose_version = DOCKER_COMPOSE_VERSION
    docker_version         = DOCKER_VERSION
  }
  context = VEGITO_DOCKER_DEBIAN_DOCKER_DIR
}
