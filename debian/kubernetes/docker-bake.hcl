variable "VEGITO_DOCKER_DEBIAN_KUBERNETES_DIR" {
  default = "${VEGITO_DOCKER_DEBIAN_DIR}/kubernetes"
}

target "vegito-debian-kubernetes-base" {
  context = VEGITO_DOCKER_DEBIAN_KUBERNETES_DIR
}
