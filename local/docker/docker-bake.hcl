variable "USE_REGISTRY_CACHE" {
  default = false
}

variable "VERSION" {
  description = "current git tag or commit version"
  default     = "dev"
}
variable "GO_VERSION" {
  description = "current Go version"
  default     = "1.24.5"
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
    "linux/arm64"
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

target "local-docker-dind-rootless-ci" {
  tags = [
    "${VEGITO_PRIVATE_REPOSITORY}/docker-dind-rootless:latest",
    "${VEGITO_PRIVATE_REPOSITORY}/docker-dind-rootless:${VERSION}",
  ]
  context    = "${LOCAL_DIR}/docker"
  dockerfile = "docker-dind-rootless.Dockerfile"
  platforms  = platforms
}

target "local-debian-ci" {
  tags = [
    "${VEGITO_PRIVATE_REPOSITORY}/debian:latest",
    "${VEGITO_PRIVATE_REPOSITORY}/debian:${VERSION}",
  ]
  context    = "${LOCAL_DIR}/docker"
  dockerfile = "debian.Dockerfile"
  platforms  = platforms
}

target "local-golang-alpine-ci" {
  tags = [
    "${VEGITO_PRIVATE_REPOSITORY}/golang-alpine:latest",
    "${VEGITO_PRIVATE_REPOSITORY}/golang-alpine:${VERSION}",
  ]
  context    = "${LOCAL_DIR}/docker"
  dockerfile = "golang-alpine.Dockerfile"
  platforms  = platforms
}

target "local-rust-ci" {
  tags = [
    "${VEGITO_PRIVATE_REPOSITORY}/rust:latest",
    "${VEGITO_PRIVATE_REPOSITORY}/rust:${VERSION}",
  ]
  context    = "${LOCAL_DIR}/docker"
  dockerfile = "rust.Dockerfile"
  platforms  = platforms
}
