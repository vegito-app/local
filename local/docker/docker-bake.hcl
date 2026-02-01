variable "USE_REGISTRY_CACHE" {
  default = false
}

variable "LOCAL_DOCKER_DIR" {
  default = "${LOCAL_DIR}/docker"
}

variable "LOCAL_DOCKER_BUILDX_LOCAL_CACHE_DIR" {
  default = "${LOCAL_DOCKER_DIR}/.containers/buildx-cache"
}

variable "VERSION" {
  description = "current git tag or commit version"
  default     = "dev"
}
variable "DOCKERHUB_REPLICA_VERSION" {
  description = "current git tag or commit version"
  default     = VERSION
}
variable "GO_VERSION" {
  description = "current Go version"
  default     = "1.25.5"
}

variable "NODE_VERSION" {
  description = "current Node version"
  default     = "22.14.0"
}

variable "OH_MY_ZSH_VERSION" {
  description = "current Oh My Zsh version"
  default     = "1.2.1"
}

variable "NVM_VERSION" {
  description = "current NVM version"
  default     = "0.40.1"
}

variable "DOCKER_VERSION" {
  description = "current Docker version"
  default     = "28.0.2"
}

variable "DOCKER_COMPOSE_VERSION" {
  description = "current Docker Compose version"
  default     = "2.34.0"
}

variable "DOCKER_BUILDX_VERSION" {
  description = "current Docker Buildx version"
  default     = "0.22.0"
}

variable "TERRAFORM_VERSION" {
  description = "current Terraform version"
  default     = "1.11.2"
}

variable "KUBECTL_VERSION" {
  description = "current Kubernetes version"
  default     = "1.32"
}

variable "K9S_VERSION" {
  description = "current K9S version"
  default     = "0.50.9"
}

variable "GITLEAKS_VERSION" {
  description = "current Gitleaks version"
  default     = "8.28.0"
}

variable "INFRA_ENV" {
  description = "production, staging or dev"
  default     = "dev"
}

variable "VEGITO_PRIVATE_REPOSITORY" {
  default = "${INFRA_ENV}-docker-repository"
}

variable "VEGITO_PUBLIC_REPOSITORY" {
  default = "${INFRA_ENV}-docker-repository-public"
}

variable "GOOGLE_CLOUD_PROJECT_ID" {
  description = "Google Cloud Project ID"
  default     = "moov-dev-439608"
}

variable "platforms" {
  default = [
    "linux/amd64",
    "linux/arm64",
  ]
}

group "local-runners" {
  targets = [
    "local-android-runners",
  ]
}

group "local-runners-ci" {
  targets = [
    "local-android-runners-ci",
  ]
}

group "local-builders" {
  targets = [
    "local-project-builder",
    "local-android-builders",
  ]
}

group "local-builders-ci" {
  targets = [
    "local-project-builder-ci",
    "local-android-builders-ci",
  ]
}

group "local-services" {
  targets = [
    "local-android-services",
    "clarinet-devnet",
    "firebase-emulators",
    "github-actions-runner",
    "vault-dev",
    "robotframework",
  ]
}

group "local-services-ci" {
  targets = [
    "local-android-services-ci",
    "clarinet-devnet-ci",
    "firebase-emulators-ci",
    "github-actions-runner-ci",
    "vault-dev-ci",
    "robotframework-ci",
  ]
}

group "local-applications" {
  targets = [
    "example-applications",
  ]
}

group "local-applications-ci" {
  targets = [
    "example-applications-ci",
  ]
}

group "local-dockerhub-ci" {
  targets = [
    "local-debian-ci",
    "local-docker-dind-rootless-ci",
    "local-golang-alpine-ci",
    "local-rust-ci",
  ]
}

variable "DOCKER_DIND_ROOTLESS_IMAGE_LATEST" {
  default = "${VEGITO_PRIVATE_REPOSITORY}/docker-dind-rootless:latest"
}

variable "DOCKER_DIND_ROOTLESS_IMAGE_VERSION" {
  default = "${VEGITO_PRIVATE_REPOSITORY}/docker-dind-rootless:${DOCKERHUB_REPLICA_VERSION}"
}

target "local-docker-dind-rootless-ci" {
  tags = [
    DOCKER_DIND_ROOTLESS_IMAGE_LATEST,
    DOCKER_DIND_ROOTLESS_IMAGE_VERSION,
  ]
  context    = "${LOCAL_DIR}/docker"
  dockerfile = "docker-dind-rootless.Dockerfile"
  platforms  = platforms
}

variable "DEBIAN_IMAGE_LATEST" {
  default = "${VEGITO_PRIVATE_REPOSITORY}/debian:latest"
}

variable "DEBIAN_IMAGE_VERSION" {
  default = "${VEGITO_PRIVATE_REPOSITORY}/debian:${DOCKERHUB_REPLICA_VERSION}"
}

target "local-debian-ci" {
  tags = [
    DEBIAN_IMAGE_LATEST,
    DEBIAN_IMAGE_VERSION,
  ]
  context    = LOCAL_DOCKER_DIR
  dockerfile = "debian.Dockerfile"
  platforms  = platforms
}

variable "GO_IMAGE_LATEST" {
  default = "${VEGITO_PRIVATE_REPOSITORY}/golang-alpine:latest"
}

variable "GO_IMAGE_VERSION" {
  default = "${VEGITO_PRIVATE_REPOSITORY}/golang-alpine:${DOCKERHUB_REPLICA_VERSION}"
}

target "local-golang-alpine-ci" {
  tags = [
    GO_IMAGE_LATEST,
    GO_IMAGE_VERSION,
  ]
  context    = LOCAL_DOCKER_DIR
  dockerfile = "golang-alpine.Dockerfile"
  platforms  = platforms
}

variable "RUST_IMAGE_LATEST" {
  default = "${VEGITO_PRIVATE_REPOSITORY}/rust:latest"
}

variable "RUST_IMAGE_VERSION" {
  default = "${VEGITO_PRIVATE_REPOSITORY}/rust:${DOCKERHUB_REPLICA_VERSION}"
}

target "local-rust-ci" {
  tags = [
    RUST_IMAGE_LATEST,
    RUST_IMAGE_VERSION,
  ]
  context    = "${LOCAL_DIR}/docker"
  dockerfile = "rust.Dockerfile"
  platforms  = platforms
}
