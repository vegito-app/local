variable "VEGITO_DOCKER_DEBIAN_NODEJS_DIR" {
  default = "${VEGITO_DOCKER_DEBIAN_DIR}/nodejs"
}

target "vegito-debian-nodejs-base" {
  inherits = ["vegito-debian-nodejs-base"]
  context  = VEGITO_DOCKER_DEBIAN_NODEJS_DIR
  args = {
    debian_version = "trixie"
    node_version   = NODE_VERSION
    nvm_version    = NVM_VERSION
  }
}
