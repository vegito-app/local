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
    "docker-golang-debian",
    "docker-debian-trixie",
    "docker-debian-trixie-golang",
    "docker-dind-rootless",
    "docker-golang-alpine",
    "docker-rust-alpine",
  ]
}

group "dockerhub-ci" {
  targets = [
    "docker-debian-ci",
    "docker-golang-debian-ci",
    "docker-debian-trixie-ci",
    "docker-debian-trixie-golang-ci",
    "docker-dind-rootless-ci",
    "docker-golang-alpine-ci",
    "docker-rust-alpine-ci",
  ]
}
