variable "USE_REGISTRY_CACHE" {
  default = false
}

variable "ENABLE_LOCAL_CACHE" {
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
  default = "docker-repository-cache"
}

variable "VEGITO_LOCAL_CACHE_IMAGES_BASE" {
  default = "${VEGITO_CACHE_REPOSITORY}/vegito-local"
}

variable "VEGITO_PRIVATE_REPOSITORY" {
  default = "docker-repository-private"
}

variable "VEGITO_PUBLIC_REPOSITORY" {
  default = "docker-repository-public"
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

variable "LOCAL_RELEASE_BUILD_MAX_PARALLELISM" {
  default = 2
}

# Groups are used to build incrementally the images in the correct order:
# - Dockerhub: the base images that we replicate to our private repository
# - Runners: the most basic level, they are used to run the services and applications
# - Builders: used to build the services, applications and the local development environments
# - Services: the dependencies of the applications, they are used to run the applications
# - Applications: the end products that we want to run and test
group "local-dockerhub" {
  targets = [
    "local-debian",
    "local-docker-dind-rootless",
    "local-golang-alpine",
    "local-rust",
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

group "local-tools" {
  targets = [
    "local-trivy",
  ]
}

group "local-tools-ci" {
  targets = [
    "local-trivy-ci",
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
    "local-clarinet-devnet",
    "local-firebase-emulators",
    "local-github-actions-runner",
    "local-vault-dev",
    "local-robotframework",
  ]
}

group "local-services-ci" {
  targets = [
    "local-android-services-ci",
    "local-clarinet-devnet-ci",
    "local-firebase-emulators-ci",
    "local-github-actions-runner-ci",
    "local-vault-dev-ci",
    "local-robotframework-ci",
    "vegito-example-application-services-ci",
  ]
}

group "local-applications" {
  targets = [
    "vegito-example-application-applications",
  ]
}

group "local-applications-ci" {
  targets = [
    "vegito-example-application-applications-ci",
  ]
}
group "default" {

  targets = [
    "local-release",
    "local-release-ci",
  ]

  max_parallelism = LOCAL_RELEASE_BUILD_MAX_PARALLELISM

}

group "local-release" {
  targets = [
    "local-tools",
    "local-runners",
    "local-builders",
    "local-services",
    "local-applications",

    "vegito-example-application-release",
  ]
}

group "local-release-ci" {
  targets = [
    "local-tools-ci",
    "local-runners-ci",
    "local-builders-ci",
    "local-services-ci",
    "local-applications-ci",

    "vegito-example-application-release-ci",
  ]
}

variable "LOCAL_DOCKER_DIND_ROOTLESS_IMAGE_LATEST" {
  default = "${VEGITO_PRIVATE_REPOSITORY}/docker-dind-rootless:latest"
}

variable "LOCAL_DOCKER_DIND_ROOTLESS_IMAGE_VERSION" {
  default = "${VEGITO_PRIVATE_REPOSITORY}/docker-dind-rootless:${DOCKERHUB_REPLICA_VERSION}"
}

variable "LOCAL_DEBIAN_IMAGE_REGISTRY_CACHE" {
  default = "${VEGITO_LOCAL_CACHE_IMAGES_BASE}/debian"
}

variable "LOCAL_GOLANG_ALPINE_IMAGE_REGISTRY_CACHE" {
  default = "${VEGITO_LOCAL_CACHE_IMAGES_BASE}/golang-alpine"
}

variable "LOCAL_RUST_IMAGE_REGISTRY_CACHE" {
  default = "${VEGITO_LOCAL_CACHE_IMAGES_BASE}/rust"
}

variable "LOCAL_DOCKER_DIND_ROOTLESS_IMAGE_REGISTRY_CACHE" {
  default = "${VEGITO_LOCAL_CACHE_IMAGES_BASE}/docker-dind-rootless"
}

variable "LOCAL_DOCKER_DIND_ROOTLESS_IMAGE_DOCKER_BUILDX_LOCAL_CACHE" {
  default = "${LOCAL_DOCKER_BUILDX_LOCAL_CACHE_DIR}/docker-dind-rootless"
}

variable "LOCAL_DOCKER_DIND_ROOTLESS_IMAGE_DOCKER_BUILDX_LOCAL_CACHE_WRITE" {
  default = "type=local,mode=max,dest=${LOCAL_DOCKER_DIND_ROOTLESS_IMAGE_DOCKER_BUILDX_LOCAL_CACHE}"
}

variable "LOCAL_DOCKER_DIND_ROOTLESS_IMAGE_DOCKER_BUILDX_LOCAL_CACHE_READ" {
  default = "type=local,src=${LOCAL_DOCKER_DIND_ROOTLESS_IMAGE_DOCKER_BUILDX_LOCAL_CACHE}"
}

group "local-docker-dind-rootless-ci" {
  targets = [
    "local-docker-dind-rootless-version-ci",
    "local-docker-dind-rootless-latest-ci",
  ]
}

target "local-docker-dind-rootless-version-ci" {
  tags = [
    LOCAL_DOCKER_DIND_ROOTLESS_IMAGE_VERSION,
  ]
  context    = "${LOCAL_DIR}/docker"
  dockerfile = "docker-dind-rootless.Dockerfile"
  cache-from = concat(
    ENABLE_LOCAL_CACHE ? [
      LOCAL_DOCKER_DIND_ROOTLESS_IMAGE_DOCKER_BUILDX_LOCAL_CACHE_READ
    ] : [],
    USE_REGISTRY_CACHE ? [
      "type=registry,ref=${LOCAL_DOCKER_DIND_ROOTLESS_IMAGE_REGISTRY_CACHE}"
    ] : [],
    [
      "type=inline,ref=${LOCAL_DOCKER_DIND_ROOTLESS_IMAGE_LATEST}"
    ]
  )
  cache-to = concat(
    ENABLE_LOCAL_CACHE ? [
      LOCAL_DOCKER_DIND_ROOTLESS_IMAGE_DOCKER_BUILDX_LOCAL_CACHE_WRITE
    ] : [],
  )
  platforms = platforms
}

target "local-docker-dind-rootless-latest-ci" {
  tags = [
    LOCAL_DOCKER_DIND_ROOTLESS_IMAGE_LATEST,
  ]
  context    = "${LOCAL_DIR}/docker"
  dockerfile = "docker-dind-rootless.Dockerfile"
  cache-from = concat(
    ENABLE_LOCAL_CACHE ? [
      LOCAL_DOCKER_DIND_ROOTLESS_IMAGE_DOCKER_BUILDX_LOCAL_CACHE_READ
    ] : [],
    USE_REGISTRY_CACHE ? [
      "type=registry,ref=${LOCAL_DOCKER_DIND_ROOTLESS_IMAGE_REGISTRY_CACHE}"
    ] : [],
    [
      "type=inline,ref=${LOCAL_DOCKER_DIND_ROOTLESS_IMAGE_LATEST}"
    ]
  )
  cache-to = [
    USE_REGISTRY_CACHE ? "type=registry,ref=${LOCAL_DOCKER_DIND_ROOTLESS_IMAGE_REGISTRY_CACHE},mode=max" : "type=inline"
  ]
  platforms = platforms
}

target "local-docker-dind-rootless" {
  tags = [
    LOCAL_DOCKER_DIND_ROOTLESS_IMAGE_VERSION,
    LOCAL_DOCKER_DIND_ROOTLESS_IMAGE_LATEST,
  ]
  context    = "${LOCAL_DIR}/docker"
  dockerfile = "docker-dind-rootless.Dockerfile"
  cache-from = concat(
    ENABLE_LOCAL_CACHE ? [
      LOCAL_DOCKER_DIND_ROOTLESS_IMAGE_DOCKER_BUILDX_LOCAL_CACHE_READ
    ] : [],
    USE_REGISTRY_CACHE ? [
      "type=registry,ref=${LOCAL_DOCKER_DIND_ROOTLESS_IMAGE_REGISTRY_CACHE}"
    ] : [],
    [
      "type=inline,ref=${LOCAL_DOCKER_DIND_ROOTLESS_IMAGE_LATEST}"
    ]
  )
  cache-to = concat(
    ENABLE_LOCAL_CACHE ? [
      LOCAL_DOCKER_DIND_ROOTLESS_IMAGE_DOCKER_BUILDX_LOCAL_CACHE_WRITE
    ] : [],
  )
}

variable "LOCAL_DEBIAN_IMAGE_DOCKER_BUILDX_LOCAL_CACHE" {
  default = "${LOCAL_DOCKER_BUILDX_LOCAL_CACHE_DIR}/debian"
}

variable "LOCAL_DEBIAN_IMAGE_DOCKER_BUILDX_LOCAL_CACHE_WRITE" {
  default = "type=local,mode=max,dest=${LOCAL_DEBIAN_IMAGE_DOCKER_BUILDX_LOCAL_CACHE}"
}

variable "LOCAL_DEBIAN_IMAGE_DOCKER_BUILDX_LOCAL_CACHE_READ" {
  default = "type=local,src=${LOCAL_DEBIAN_IMAGE_DOCKER_BUILDX_LOCAL_CACHE}"
}

variable "LOCAL_DEBIAN_IMAGE_LATEST" {
  default = "${VEGITO_PRIVATE_REPOSITORY}/debian:latest"
}

variable "LOCAL_DEBIAN_IMAGE_VERSION" {
  default = "${VEGITO_PRIVATE_REPOSITORY}/debian:${DOCKERHUB_REPLICA_VERSION}"
}

group "local-debian-ci" {
  targets = [
    "local-debian-version-ci",
    "local-debian-latest-ci",
  ]
}

target "local-debian-version-ci" {
  tags = [
    LOCAL_DEBIAN_IMAGE_VERSION,
  ]
  context    = LOCAL_DOCKER_DIR
  dockerfile = "debian.Dockerfile"
  cache-from = concat(
    USE_REGISTRY_CACHE ? [
      "type=registry,ref=${LOCAL_DEBIAN_IMAGE_REGISTRY_CACHE}"
    ] : [],
    ENABLE_LOCAL_CACHE ? [
      LOCAL_DEBIAN_IMAGE_DOCKER_BUILDX_LOCAL_CACHE_READ
    ] : [],
    [
      "type=inline,ref=${LOCAL_DEBIAN_IMAGE_LATEST}"
    ]
  )
  cache-to = concat(
    ENABLE_LOCAL_CACHE ? [
      LOCAL_DEBIAN_IMAGE_DOCKER_BUILDX_LOCAL_CACHE_WRITE
    ] : [],
  )
  platforms = platforms
}

target "local-debian-latest-ci" {
  tags = [
    LOCAL_DEBIAN_IMAGE_LATEST,
  ]
  context    = LOCAL_DOCKER_DIR
  dockerfile = "debian.Dockerfile"
  cache-from = concat(
    USE_REGISTRY_CACHE ? [
      "type=registry,ref=${LOCAL_DEBIAN_IMAGE_REGISTRY_CACHE}"
    ] : [],
    ENABLE_LOCAL_CACHE ? [
      LOCAL_DEBIAN_IMAGE_DOCKER_BUILDX_LOCAL_CACHE_READ
    ] : [],
    [
      "type=inline,ref=${LOCAL_DEBIAN_IMAGE_LATEST}"
    ]
  )
  cache-to = [
    USE_REGISTRY_CACHE ? "type=registry,ref=${LOCAL_DEBIAN_IMAGE_REGISTRY_CACHE},mode=max" : "",
    "type=inline"
  ]
  platforms = platforms
}

target "local-debian" {
  tags = [
    LOCAL_DEBIAN_IMAGE_LATEST,
  ]
  context    = LOCAL_DOCKER_DIR
  dockerfile = "debian.Dockerfile"
  cache-from = concat(
    USE_REGISTRY_CACHE ? [
      "type=registry,ref=${LOCAL_DEBIAN_IMAGE_REGISTRY_CACHE}"
    ] : [],
    ENABLE_LOCAL_CACHE ? [
      LOCAL_DEBIAN_IMAGE_DOCKER_BUILDX_LOCAL_CACHE_READ
    ] : [],
    [
      "type=inline,ref=${LOCAL_DEBIAN_IMAGE_LATEST}"
    ]
  )
  cache-to = concat(
    ENABLE_LOCAL_CACHE ? [
      LOCAL_GOLANG_ALPINE_IMAGE_DOCKER_BUILDX_LOCAL_CACHE_WRITE
    ] : []
  )
}

variable "LOCAL_GO_IMAGE_LATEST" {
  default = "${VEGITO_PRIVATE_REPOSITORY}/golang-alpine:latest"
}

variable "LOCAL_GO_IMAGE_VERSION" {
  default = "${VEGITO_PRIVATE_REPOSITORY}/golang-alpine:${DOCKERHUB_REPLICA_VERSION}"
}

variable "LOCAL_GOLANG_ALPINE_IMAGE_DOCKER_BUILDX_LOCAL_CACHE" {
  default = "${LOCAL_DOCKER_BUILDX_LOCAL_CACHE_DIR}/golang-alpine"
}

variable "LOCAL_GOLANG_ALPINE_IMAGE_DOCKER_BUILDX_LOCAL_CACHE_WRITE" {
  default = "type=local,mode=max,dest=${LOCAL_GOLANG_ALPINE_IMAGE_DOCKER_BUILDX_LOCAL_CACHE}"
}

variable "LOCAL_GOLANG_ALPINE_IMAGE_DOCKER_BUILDX_LOCAL_CACHE_READ" {
  default = "type=local,src=${LOCAL_GOLANG_ALPINE_IMAGE_DOCKER_BUILDX_LOCAL_CACHE}"
}

group "local-golang-alpine-ci" {
  targets = [
    "local-golang-alpine-version-ci",
    "local-golang-alpine-latest-ci",
  ]
}

target "local-golang-alpine-version-ci" {

  tags = [
    LOCAL_GO_IMAGE_VERSION,
  ]
  context    = LOCAL_DOCKER_DIR
  dockerfile = "golang-alpine.Dockerfile"
  cache-from = concat(
    USE_REGISTRY_CACHE ? [
      "type=registry,ref=${LOCAL_GOLANG_ALPINE_IMAGE_REGISTRY_CACHE}"
    ] : [],
    ENABLE_LOCAL_CACHE ? [
      LOCAL_GOLANG_ALPINE_IMAGE_DOCKER_BUILDX_LOCAL_CACHE_READ
    ] : [],
    [
      "type=inline,ref=${LOCAL_GO_IMAGE_LATEST}"
    ]
  )
  cache-to = [
    USE_REGISTRY_CACHE ? "type=registry,ref=${LOCAL_GOLANG_ALPINE_IMAGE_REGISTRY_CACHE},mode=max" : "type=inline"
  ]
  platforms = platforms
}

target "local-golang-alpine-latest-ci" {
  tags = [
    LOCAL_GO_IMAGE_LATEST,
  ]
  context    = LOCAL_DOCKER_DIR
  dockerfile = "golang-alpine.Dockerfile"
  cache-from = concat(
    USE_REGISTRY_CACHE ? [
      "type=registry,ref=${LOCAL_GOLANG_ALPINE_IMAGE_REGISTRY_CACHE}"
    ] : [],
    ENABLE_LOCAL_CACHE ? [
      LOCAL_GOLANG_ALPINE_IMAGE_DOCKER_BUILDX_LOCAL_CACHE_READ
    ] : [],
    [
      "type=inline,ref=${LOCAL_GO_IMAGE_LATEST}"
    ]
  )
  cache-to = [
    USE_REGISTRY_CACHE ? "type=registry,ref=${LOCAL_GOLANG_ALPINE_IMAGE_REGISTRY_CACHE},mode=max" : "",
    "type=inline"
  ]
  platforms = platforms
}

target "local-golang-alpine" {
  tags = [
    LOCAL_GO_IMAGE_VERSION,
    LOCAL_GO_IMAGE_LATEST,
  ]
  context    = LOCAL_DOCKER_DIR
  dockerfile = "golang-alpine.Dockerfile"
  cache-from = concat(
    USE_REGISTRY_CACHE ? [
      "type=registry,ref=${LOCAL_GOLANG_ALPINE_IMAGE_REGISTRY_CACHE}"
    ] : [],
    ENABLE_LOCAL_CACHE ? [
      LOCAL_GOLANG_ALPINE_IMAGE_DOCKER_BUILDX_LOCAL_CACHE_READ
    ] : [],
    [
      "type=inline,ref=${LOCAL_GO_IMAGE_LATEST}"
    ]
  )
  cache-to = concat(
    ENABLE_LOCAL_CACHE ? [
      LOCAL_GOLANG_ALPINE_IMAGE_DOCKER_BUILDX_LOCAL_CACHE_WRITE
    ] : []
  )
}

variable "LOCAL_RUST_IMAGE_LATEST" {
  default = "${VEGITO_PRIVATE_REPOSITORY}/rust:latest"
}

variable "LOCAL_RUST_IMAGE_VERSION" {
  default = "${VEGITO_PRIVATE_REPOSITORY}/rust:${DOCKERHUB_REPLICA_VERSION}"
}

variable "LOCAL_RUST_IMAGE_DOCKER_BUILDX_LOCAL_CACHE" {
  default = "${LOCAL_DOCKER_BUILDX_LOCAL_CACHE_DIR}/rust"
}

variable "LOCAL_RUST_IMAGE_DOCKER_BUILDX_LOCAL_CACHE_WRITE" {
  default = "type=local,mode=max,dest=${LOCAL_RUST_IMAGE_DOCKER_BUILDX_LOCAL_CACHE}"
}

variable "LOCAL_RUST_IMAGE_DOCKER_BUILDX_LOCAL_CACHE_READ" {
  default = "type=local,src=${LOCAL_RUST_IMAGE_DOCKER_BUILDX_LOCAL_CACHE}"
}

group "local-rust-ci" {
  targets = [
    "local-rust-version-ci",
    "local-rust-latest-ci",
  ]
}

target "local-rust-version-ci" {
  tags = [
    LOCAL_RUST_IMAGE_VERSION,
  ]
  context    = "${LOCAL_DIR}/docker"
  dockerfile = "rust.Dockerfile"
  cache-from = concat(
    USE_REGISTRY_CACHE ? [
      "type=registry,ref=${LOCAL_RUST_IMAGE_REGISTRY_CACHE}"
    ] : [],
    ENABLE_LOCAL_CACHE ? [
      LOCAL_RUST_IMAGE_DOCKER_BUILDX_LOCAL_CACHE_READ
    ] : [],
    [
      "type=inline,ref=${LOCAL_RUST_IMAGE_LATEST}"
    ]
  )
  cache-to = concat(
    ENABLE_LOCAL_CACHE ? [
      LOCAL_RUST_IMAGE_DOCKER_BUILDX_LOCAL_CACHE_WRITE
    ] : [],
  )
  platforms = platforms
}

target "local-rust-latest-ci" {
  tags = [
    LOCAL_RUST_IMAGE_LATEST,
  ]
  context    = "${LOCAL_DIR}/docker"
  dockerfile = "rust.Dockerfile"
  cache-from = concat(
    USE_REGISTRY_CACHE ? [
      "type=registry,ref=${LOCAL_RUST_IMAGE_REGISTRY_CACHE}"
    ] : [],
    ENABLE_LOCAL_CACHE ? [
      LOCAL_RUST_IMAGE_DOCKER_BUILDX_LOCAL_CACHE_READ
    ] : [],
    [
      "type=inline,ref=${LOCAL_RUST_IMAGE_LATEST}"
    ]
  )
  cache-to = [
    USE_REGISTRY_CACHE ? "type=registry,ref=${LOCAL_RUST_IMAGE_REGISTRY_CACHE},mode=max" : "",
    "type=inline"
  ]
  platforms = platforms
}

target "local-rust" {
  tags = [
    LOCAL_RUST_IMAGE_LATEST,
    LOCAL_RUST_IMAGE_VERSION,
  ]
  context    = "${LOCAL_DIR}/docker"
  dockerfile = "rust.Dockerfile"
  cache-from = concat(
    USE_REGISTRY_CACHE ? [
      "type=registry,ref=${LOCAL_RUST_IMAGE_REGISTRY_CACHE}"
    ] : [],
    ENABLE_LOCAL_CACHE ? [
      LOCAL_RUST_IMAGE_DOCKER_BUILDX_LOCAL_CACHE_READ
    ] : [],
    [
      "type=inline,ref=${LOCAL_RUST_IMAGE_LATEST}"
    ]
  )
  cache-to = concat(
    ENABLE_LOCAL_CACHE ? [
      LOCAL_RUST_IMAGE_DOCKER_BUILDX_LOCAL_CACHE_WRITE
    ] : []
  )
}
