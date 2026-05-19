variable "VEGITO_DOCKER_IO_HUB_DIR" {
  default = "${VEGITO_DOCKER_DIR}/docker.io"
}

# Groups are used to build incrementally the images in the correct order:
# - Dockerhub: the base images that we replicate to our private repository
# - Runners: the most basic level, they are used to run the services and applications
# - Builders: used to build the services, applications and the local development environments
# - Services: the dependencies of the applications, they are used to run the applications
# - Applications: the end products that we want to run and test
group "dockerhub" {
  targets = [
    "docker-debian",
    "docker-dind-rootless",
    "docker-alpine-golang",
    "docker-alpine-rust",
  ]
}

group "dockerhub-ci" {
  targets = [
    "docker-debian-ci",
    "docker-dind-rootless-ci",
    "docker-alpine-golang-ci",
    "docker-alpine-rust-ci",
  ]
}
