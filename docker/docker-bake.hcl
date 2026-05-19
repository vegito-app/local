variable "VEGITO_DOCKER_PUBLIC_IMAGES_BASE_NAME" {
  default = "${VEGITO_PUBLIC_REPOSITORY}/vegito-docker"
}

variable "VEGITO_DOCKER_PRIVATE_IMAGES_BASE" {
  default = "${VEGITO_PUBLIC_REPOSITORY}/vegito-docker"
}

variable "USE_REGISTRY_CACHE" {
  default = false
  type    = bool
}

variable "ENABLE_LOCAL_CACHE" {
  default = false
  type    = bool
}

variable "VEGITO_DOCKER_DIR" {
  default = "."
}

variable "VEGITO_DOCKER_BUILDX_LOCAL_CACHE_DIR" {
  default = "${VEGITO_DOCKER_DIR}/.containers/buildx-cache"
}

variable "VERSION" {
  description = "current git tag or commit version"
  default     = "dev"
}

variable "GO_VERSION" {
  description = "current Go version"
  default     = "1.26.1"
}

variable "TRIVY_VERSION" {
  default = "0.70.0"
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

variable "VEGITO_CACHE_REPOSITORY" {
  default = "vegito-docker-repository-cache"
}

variable "VEGITO_CACHE_IMAGES_BASE" {
  default = "${VEGITO_CACHE_REPOSITORY}/vegito-docker"
}

variable "VEGITO_PUBLIC_REPOSITORY" {
  default = "vegito-docker-repository-private"
}

variable "VEGITO_PUBLIC_REPOSITORY" {
  default = "vegito-docker-repository-public"
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

variable "VEGITO_RELEASE_BUILD_MAX_PARALLELISM" {
  default = 2
}

# Groups are used to build incrementally the images in the correct order:
# - Dockerhub: the base images that we replicate to our private repository
# - Runners: the most basic level, they are used to run the services and applications
# - Builders: used to build the services, applications and the local development environments
# - Services: the dependencies of the applications, they are used to run the applications
# - Applications: the end products that we want to run and test
group "runners" {
  targets = [
    "vegito-debian",
  ]
}

group "runners-ci" {
  targets = [
    "vegito-debian",
    "vegito-debian-ci",
  ]
}


group "default" {

  targets = [
    "release",
    "release-ci",
  ]
  pull            = true
  max_parallelism = VEGITO_RELEASE_BUILD_MAX_PARALLELISM

}

group "release" {
  targets = [
    "dockerhub",
    "runners",
  ]
}

group "release-ci" {
  targets = [
    "dockerhub-ci",
    "runners-ci",
  ]
}
