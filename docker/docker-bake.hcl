variable "VEGITO_PUBLIC_IMAGES_BASE_NAME" {
  default = "${VEGITO_PUBLIC_REPOSITORY}/vegito-docker"
}

variable "VEGITO_PRIVATE_IMAGES_BASE" {
  default = "${VEGITO_PRIVATE_REPOSITORY}/vegito-docker"
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

variable "VEGITO_PRIVATE_REPOSITORY" {
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
group "dockerhub" {
  targets = [
    "debian",
    "vegito-docker-dind-rootless",
    "golang-alpine",
    "rust",
  ]
}

group "dockerhub-ci" {
  targets = [
    "vegito-debian-latest-ci",
    "vegito-debian-version-ci",

    "vegito-docker-dind-rootless-ci",
    "golang-alpine-ci",
    "rust-ci",
  ]
}

group "runners" {
  targets = [
    "vegito-debian-desktop-x",
  ]
}

group "runners-ci" {
  targets = [
    "vegito-debian-desktop-x-ci",
  ]
}

group "tools-ci" {
  targets = [
    "vegito-debian-flutter-ci",
    "vegito-debian-flutter-desktop-x-ci",
  ]
}

gtoup "tools" {
  targets = [
    "vegito-debian-flutter",
    "vegito-debian-flutter-desktop-x",
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
    "tools",
  ]
}

group "release-ci" {
  targets = [
    "dockerhub-ci",
    "vegito-debian-ci",
    "runners-ci",
    "tools-ci",
  ]
}

variable "VEGITO_DOCKER_DIND_ROOTLESS_IMAGE_LATEST" {
  default = "${VEGITO_PRIVATE_REPOSITORY}/docker-dind-rootless:latest"
}

variable "VEGITO_DOCKER_DIND_ROOTLESS_IMAGE_VERSION" {
  default = "${VEGITO_PRIVATE_REPOSITORY}/docker-dind-rootless:${VERSION}"
}

variable "VEGITO_GOLANG_ALPINE_IMAGE_REGISTRY_CACHE" {
  default = "${VEGITO_CACHE_IMAGES_BASE}/golang-alpine"
}

variable "VEGITO_RUST_IMAGE_REGISTRY_CACHE" {
  default = "${VEGITO_CACHE_IMAGES_BASE}/rust"
}

variable "VEGITO_DEBIAN_PYTHON_IMAGE_REGISTRY_CACHE" {
  default = "${VEGITO_CACHE_IMAGES_BASE}/python"
}

variable "VEGITO_DOCKER_DIND_ROOTLESS_IMAGE_REGISTRY_CACHE" {
  default = "${VEGITO_CACHE_IMAGES_BASE}/docker-dind-rootless"
}

variable "VEGITO_DOCKER_DIND_ROOTLESS_IMAGE_DOCKER_BUILDX_LOCAL_CACHE" {
  default = "${VEGITO_DOCKER_BUILDX_LOCAL_CACHE_DIR}/docker-dind-rootless"
}

variable "VEGITO_DOCKER_DIND_ROOTLESS_IMAGE_DOCKER_BUILDX_LOCAL_CACHE_WRITE" {
  default = "type=local,mode=max,dest=${VEGITO_DOCKER_DIND_ROOTLESS_IMAGE_DOCKER_BUILDX_LOCAL_CACHE}"
}

variable "VEGITO_DOCKER_DIND_ROOTLESS_IMAGE_DOCKER_BUILDX_LOCAL_CACHE_READ" {
  default = "type=local,src=${VEGITO_DOCKER_DIND_ROOTLESS_IMAGE_DOCKER_BUILDX_LOCAL_CACHE}"
}

group "vegito-docker-dind-rootless-ci" {
  targets = [
    "vegito-docker-dind-rootless-version-ci",
    "vegito-docker-dind-rootless-latest-ci",
  ]
}

target "vegito-docker-dind-rootless-version-ci" {
  tags = [
    VEGITO_DOCKER_DIND_ROOTLESS_IMAGE_VERSION,
  ]
  context    = VEGITO_DOCKER_DIR
  dockerfile = "docker-dind-rootless.Dockerfile"
  cache-from = concat(
    ENABLE_LOCAL_CACHE ? [
      VEGITO_DOCKER_DIND_ROOTLESS_IMAGE_DOCKER_BUILDX_LOCAL_CACHE_READ
    ] : [],
    USE_REGISTRY_CACHE ? [
      "type=registry,ref=${VEGITO_DOCKER_DIND_ROOTLESS_IMAGE_REGISTRY_CACHE}"
    ] : [],
    [
      "type=inline,ref=${VEGITO_DOCKER_DIND_ROOTLESS_IMAGE_LATEST}"
    ]
  )
  cache-to = concat(
    ENABLE_LOCAL_CACHE ? [
      VEGITO_DOCKER_DIND_ROOTLESS_IMAGE_DOCKER_BUILDX_LOCAL_CACHE_WRITE
    ] : [],
  )
  platforms = platforms
}

target "vegito-docker-dind-rootless-latest-ci" {
  tags = [
    VEGITO_DOCKER_DIND_ROOTLESS_IMAGE_LATEST,
  ]
  context    = VEGITO_DOCKER_DIR
  dockerfile = "docker-dind-rootless.Dockerfile"
  cache-from = concat(
    ENABLE_LOCAL_CACHE ? [
      VEGITO_DOCKER_DIND_ROOTLESS_IMAGE_DOCKER_BUILDX_LOCAL_CACHE_READ
    ] : [],
    USE_REGISTRY_CACHE ? [
      "type=registry,ref=${VEGITO_DOCKER_DIND_ROOTLESS_IMAGE_REGISTRY_CACHE}"
    ] : [],
    [
      "type=inline,ref=${VEGITO_DOCKER_DIND_ROOTLESS_IMAGE_LATEST}"
    ]
  )
  cache-to = [
    USE_REGISTRY_CACHE ? "type=registry,ref=${VEGITO_DOCKER_DIND_ROOTLESS_IMAGE_REGISTRY_CACHE},mode=max" : "type=inline"
  ]
  platforms = platforms
}

target "vegito-docker-dind-rootless" {
  tags = [
    VEGITO_DOCKER_DIND_ROOTLESS_IMAGE_VERSION,
    VEGITO_DOCKER_DIND_ROOTLESS_IMAGE_LATEST,
  ]
  context    = VEGITO_DOCKER_DIR
  dockerfile = "docker-dind-rootless.Dockerfile"
  cache-from = concat(
    ENABLE_LOCAL_CACHE ? [
      VEGITO_DOCKER_DIND_ROOTLESS_IMAGE_DOCKER_BUILDX_LOCAL_CACHE_READ
    ] : [],
    USE_REGISTRY_CACHE ? [
      "type=registry,ref=${VEGITO_DOCKER_DIND_ROOTLESS_IMAGE_REGISTRY_CACHE}"
    ] : [],
    [
      "type=inline,ref=${VEGITO_DOCKER_DIND_ROOTLESS_IMAGE_LATEST}"
    ]
  )
  cache-to = concat(
    ENABLE_LOCAL_CACHE ? [
      VEGITO_DOCKER_DIND_ROOTLESS_IMAGE_DOCKER_BUILDX_LOCAL_CACHE_WRITE
    ] : [],
  )
}

variable "VEGITO_GO_IMAGE_LATEST" {
  default = "${VEGITO_PRIVATE_REPOSITORY}/golang-alpine:latest"
}

variable "VEGITO_GO_IMAGE_VERSION" {
  default = "${VEGITO_PRIVATE_REPOSITORY}/golang-alpine:${VERSION}"
}

variable "VEGITO_GOLANG_ALPINE_IMAGE_DOCKER_BUILDX_LOCAL_CACHE" {
  default = "${VEGITO_DOCKER_BUILDX_LOCAL_CACHE_DIR}/golang-alpine"
}

variable "VEGITO_GOLANG_ALPINE_IMAGE_DOCKER_BUILDX_LOCAL_CACHE_WRITE" {
  default = "type=local,mode=max,dest=${VEGITO_GOLANG_ALPINE_IMAGE_DOCKER_BUILDX_LOCAL_CACHE}"
}

variable "VEGITO_GOLANG_ALPINE_IMAGE_DOCKER_BUILDX_LOCAL_CACHE_READ" {
  default = "type=local,src=${VEGITO_GOLANG_ALPINE_IMAGE_DOCKER_BUILDX_LOCAL_CACHE}"
}

group "golang-alpine-ci" {
  targets = [
    "golang-alpine-version-ci",
    "golang-alpine-latest-ci",
  ]
}

target "golang-alpine-version-ci" {

  tags = [
    VEGITO_GO_IMAGE_VERSION,
  ]
  context    = VEGITO_DOCKER_DIR
  dockerfile = "golang-alpine.Dockerfile"
  cache-from = concat(
    USE_REGISTRY_CACHE ? [
      "type=registry,ref=${VEGITO_GOLANG_ALPINE_IMAGE_REGISTRY_CACHE}"
    ] : [],
    ENABLE_LOCAL_CACHE ? [
      VEGITO_GOLANG_ALPINE_IMAGE_DOCKER_BUILDX_LOCAL_CACHE_READ
    ] : [],
    [
      "type=inline,ref=${VEGITO_GO_IMAGE_LATEST}"
    ]
  )
  cache-to = [
    USE_REGISTRY_CACHE ? "type=registry,ref=${VEGITO_GOLANG_ALPINE_IMAGE_REGISTRY_CACHE},mode=max" : "type=inline"
  ]
  platforms = platforms
}

target "golang-alpine-latest-ci" {
  tags = [
    VEGITO_GO_IMAGE_LATEST,
  ]
  context    = VEGITO_DOCKER_DIR
  dockerfile = "golang-alpine.Dockerfile"
  cache-from = concat(
    USE_REGISTRY_CACHE ? [
      "type=registry,ref=${VEGITO_GOLANG_ALPINE_IMAGE_REGISTRY_CACHE}"
    ] : [],
    ENABLE_LOCAL_CACHE ? [
      VEGITO_GOLANG_ALPINE_IMAGE_DOCKER_BUILDX_LOCAL_CACHE_READ
    ] : [],
    [
      "type=inline,ref=${VEGITO_GO_IMAGE_LATEST}"
    ]
  )
  cache-to = [
    USE_REGISTRY_CACHE ? "type=registry,ref=${VEGITO_GOLANG_ALPINE_IMAGE_REGISTRY_CACHE},mode=max" : "",
    "type=inline"
  ]
  platforms = platforms
}

target "golang-alpine" {
  tags = [
    VEGITO_GO_IMAGE_VERSION,
    VEGITO_GO_IMAGE_LATEST,
  ]
  context    = VEGITO_DOCKER_DIR
  dockerfile = "golang-alpine.Dockerfile"
  cache-from = concat(
    USE_REGISTRY_CACHE ? [
      "type=registry,ref=${VEGITO_GOLANG_ALPINE_IMAGE_REGISTRY_CACHE}"
    ] : [],
    ENABLE_LOCAL_CACHE ? [
      VEGITO_GOLANG_ALPINE_IMAGE_DOCKER_BUILDX_LOCAL_CACHE_READ
    ] : [],
    [
      "type=inline,ref=${VEGITO_GO_IMAGE_LATEST}"
    ]
  )
  cache-to = concat(
    ENABLE_LOCAL_CACHE ? [
      VEGITO_GOLANG_ALPINE_IMAGE_DOCKER_BUILDX_LOCAL_CACHE_WRITE
    ] : []
  )
}

variable "VEGITO_RUST_IMAGE_LATEST" {
  default = "${VEGITO_PRIVATE_REPOSITORY}/rust:latest"
}

variable "VEGITO_RUST_IMAGE_VERSION" {
  default = "${VEGITO_PRIVATE_REPOSITORY}/rust:${VERSION}"
}

variable "VEGITO_RUST_IMAGE_DOCKER_BUILDX_LOCAL_CACHE" {
  default = "${VEGITO_DOCKER_BUILDX_LOCAL_CACHE_DIR}/rust"
}

variable "VEGITO_RUST_IMAGE_DOCKER_BUILDX_LOCAL_CACHE_WRITE" {
  default = "type=local,mode=max,dest=${VEGITO_RUST_IMAGE_DOCKER_BUILDX_LOCAL_CACHE}"
}

variable "VEGITO_RUST_IMAGE_DOCKER_BUILDX_LOCAL_CACHE_READ" {
  default = "type=local,src=${VEGITO_RUST_IMAGE_DOCKER_BUILDX_LOCAL_CACHE}"
}

group "rust-ci" {
  targets = [
    "rust-version-ci",
    "rust-latest-ci",
  ]
}

target "rust-version-ci" {
  tags = [
    VEGITO_RUST_IMAGE_VERSION,
  ]
  context    = VEGITO_DOCKER_DIR
  dockerfile = "rust.Dockerfile"
  cache-from = concat(
    USE_REGISTRY_CACHE ? [
      "type=registry,ref=${VEGITO_RUST_IMAGE_REGISTRY_CACHE}"
    ] : [],
    ENABLE_LOCAL_CACHE ? [
      VEGITO_RUST_IMAGE_DOCKER_BUILDX_LOCAL_CACHE_READ
    ] : [],
    [
      "type=inline,ref=${VEGITO_RUST_IMAGE_LATEST}"
    ]
  )
  cache-to = concat(
    ENABLE_LOCAL_CACHE ? [
      VEGITO_RUST_IMAGE_DOCKER_BUILDX_LOCAL_CACHE_WRITE
    ] : [],
  )
  platforms = platforms
}

target "rust-latest-ci" {
  tags = [
    VEGITO_RUST_IMAGE_LATEST,
  ]
  context    = VEGITO_DOCKER_DIR
  dockerfile = "rust.Dockerfile"
  cache-from = concat(
    USE_REGISTRY_CACHE ? [
      "type=registry,ref=${VEGITO_RUST_IMAGE_REGISTRY_CACHE}"
    ] : [],
    ENABLE_LOCAL_CACHE ? [
      VEGITO_RUST_IMAGE_DOCKER_BUILDX_LOCAL_CACHE_READ
    ] : [],
    [
      "type=inline,ref=${VEGITO_RUST_IMAGE_LATEST}"
    ]
  )
  cache-to = [
    USE_REGISTRY_CACHE ? "type=registry,ref=${VEGITO_RUST_IMAGE_REGISTRY_CACHE},mode=max" : "",
    "type=inline"
  ]
  platforms = platforms
}

target "rust" {
  tags = [
    VEGITO_RUST_IMAGE_LATEST,
    VEGITO_RUST_IMAGE_VERSION,
  ]
  context    = VEGITO_DOCKER_DIR
  dockerfile = "rust.Dockerfile"
  cache-from = concat(
    USE_REGISTRY_CACHE ? [
      "type=registry,ref=${VEGITO_RUST_IMAGE_REGISTRY_CACHE}"
    ] : [],
    ENABLE_LOCAL_CACHE ? [
      VEGITO_RUST_IMAGE_DOCKER_BUILDX_LOCAL_CACHE_READ
    ] : [],
    [
      "type=inline,ref=${VEGITO_RUST_IMAGE_LATEST}"
    ]
  )
  cache-to = concat(
    ENABLE_LOCAL_CACHE ? [
      VEGITO_RUST_IMAGE_DOCKER_BUILDX_LOCAL_CACHE_WRITE
    ] : []
  )
}
