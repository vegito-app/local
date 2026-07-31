variable "LOCAL_DIR" {
  default = "."
}

variable "USE_REGISTRY_CACHE" {
  default = false
  type    = bool
}

variable "ENABLE_LOCAL_CACHE" {
  default = false
  type    = bool
}

variable "LOCAL_DOCKER_BUILDX_LOCAL_CACHE_DIR" {
  default = "${LOCAL_DIR}/.containers/buildx-cache"
}

variable "VEGITO_LOCAL_CACHE_REPOSITORY" {
  default = "vegito-local-repository-cache"
}

variable "VEGITO_LOCAL_CACHE_IMAGES_BASE" {
  default = "${VEGITO_LOCAL_CACHE_REPOSITORY}/vegito-local"
}

variable "VEGITO_DOCKER_PRIVATE_REPOSITORY" {
  default = "vegito-docker-repository-private"
}

variable "VEGITO_DOCKER_PUBLIC_REPOSITORY" {
  default = "vegito-docker-repository-public"
}

variable "VEGITO_LOCAL_PUBLIC_IMAGES_BASE_NAME" {
  default = "${VEGITO_DOCKER_PUBLIC_REPOSITORY}/vegito-local"
}

variable "VEGITO_DOCKER_PUBLIC_IMAGES_BASE_NAME" {
  default = "${VEGITO_DOCKER_PUBLIC_REPOSITORY}/vegito-docker"
}

variable "DEBIAN_VERSION_CODENAME" {
  default = "trixie"
}

variable "VEGITO_DOCKER_DEBIAN_CONTEXT" {
  default = "docker-image://${VEGITO_DOCKER_PUBLIC_IMAGES_BASE_NAME}:trixie-debian-latest"
}

variable "VEGITO_DOCKER_DEBIAN_PROJECT_CONTEXT" {
  default = "docker-image://${VEGITO_DOCKER_PUBLIC_IMAGES_BASE_NAME}:trixie-debian-project-latest"
}

variable "VEGITO_DOCKER_DEBIAN_PROJECT_GOLANG_CONTEXT" {
  default = "docker-image://${VEGITO_DOCKER_PUBLIC_IMAGES_BASE_NAME}:trixie-debian-project-golang-latest"
}

variable "VEGITO_DOCKER_DEBIAN_PROJECT_GOLANG_CONTEXT" {
  default = "docker-image://${VEGITO_DOCKER_PUBLIC_IMAGES_BASE_NAME}:trixie-debian-project-golang-docker-latest"
}

variable "VEGITO_DOCKER_DEBIAN_IMAGE_VERSION" {
  default = "${VEGITO_DOCKER_PUBLIC_IMAGES_BASE_NAME}:debian-${VERSION}"
}

variable "VEGITO_DOCKER_ALPINE_RUST_CONTEXT" {
  default = "docker-image://${VEGITO_DOCKER_PUBLIC_IMAGES_BASE_NAME}:rust-alpine-latest"
}

variable "VEGITO_DOCKER_DEBIAN_ROBOTFRAMEWORK_CONTEXT" {
  default = "docker-image://${VEGITO_DOCKER_PUBLIC_IMAGES_BASE_NAME}:debian-robotframework-latest"
}

variable "VEGITO_DOCKER_DEBIAN_DESKTOP_X_CONTEXT" {
  default = "docker-image://${VEGITO_DOCKER_PUBLIC_IMAGES_BASE_NAME}:trixie-debian-desktop-x-latest"
}

variable "VEGITO_DOCKER_DEBIAN_FLUTTER_DESKTOP_X_CONTEXT" {
  default = "docker-image://${VEGITO_DOCKER_PUBLIC_IMAGES_BASE_NAME}:trixie-debian-flutter-desktop-x-latest"
}

variable "VEGITO_DOCKER_HUB_GOLANG_DEBIAN_CONTEXT" {
  default = "docker-image://${VEGITO_DOCKER_PUBLIC_IMAGES_BASE_NAME}:trixie-debian-project-${VERSION}"
}

variable "VEGITO_DOCKER_TRIXIE_DEBIAN_GOLANG_PROJECT_BUILDER_X_CONTEXT" {
  default = "docker-image://${VEGITO_DOCKER_PUBLIC_IMAGES_BASE_NAME}:trixie-debian-golang-project-builder-docker-latest"
}

variable "VEGITO_DOCKER_DEBIAN_DOCKERD_CONTEXT" {
  default = "docker-image://${VEGITO_DOCKER_PUBLIC_IMAGES_BASE_NAME}:trixie-debian-dockerd-latest"
}

variable "platforms" {
  default = [
    "linux/amd64",
    "linux/arm64",
  ]
}

group "local-services" {
  targets = [
    "local-android-services",
    "local-clarinet-devnet",
    "local-firebase-emulators",
    "local-github-actions-runner",
    "local-vault-dev",
  ]
}

group "local-services-ci" {
  targets = [
    "local-android-services-ci",
    "local-clarinet-devnet-ci",
    "local-firebase-emulators-ci",
    "local-github-actions-runner-ci",
    "local-vault-dev-ci",
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
    "local-services",
  ]
}

group "release-ci" {
  targets = [
    "local-services-ci",
  ]
}

variable "LOCAL_BUILDER_IMAGE_VERSION" {
  default = "${VEGITO_LOCAL_PUBLIC_IMAGES_BASE_NAME}:builder-${VERSION}"
}

variable "LOCAL_BUILDER_IMAGE_LATEST" {
  default = "${VEGITO_LOCAL_PUBLIC_IMAGES_BASE_NAME}:builder-latest"
}

variable "LOCAL_BUILDER_IMAGE_DOCKER_BUILDX_LOCAL_CACHE" {
  default = "${LOCAL_DOCKER_BUILDX_LOCAL_CACHE_DIR}/local-builder"
}

variable "LOCAL_BUILDER_IMAGE_DOCKER_BUILDX_LOCAL_CACHE_VERSION" {
  default = "${LOCAL_DOCKER_BUILDX_LOCAL_CACHE_DIR}/local-builder-version"
}

variable "LOCAL_BUILDER_IMAGE_DOCKER_BUILDX_LOCAL_CACHE_LATEST" {
  default = "${LOCAL_DOCKER_BUILDX_LOCAL_CACHE_DIR}/local-builder-latest"
}

variable "LOCAL_BUILDER_IMAGE_REGISTRY_CACHE" {
  default = "${VEGITO_LOCAL_PUBLIC_IMAGES_BASE_NAME}/cache/builder"
}

variable "LOCAL_BUILDER_IMAGE_REGISTRY_CACHE_CI" {
  default = "${VEGITO_LOCAL_PUBLIC_IMAGES_BASE_NAME}/cache/builder/ci"
}

variable "LOCAL_BUILDER_IMAGE_DOCKER_BUILDX_CACHE_WRITE" {
  description = "local write cache for local-builder image build"
  default     = "type=local,mode=max,dest=${LOCAL_BUILDER_IMAGE_DOCKER_BUILDX_LOCAL_CACHE}"
}

variable "LOCAL_BUILDER_IMAGE_DOCKER_BUILDX_LOCAL_CACHE_READ" {
  description = "local read cache for local-builder image build (cannot be used before first write)"
  default     = "type=local,src=${LOCAL_BUILDER_IMAGE_DOCKER_BUILDX_LOCAL_CACHE}"
}

variable "LOCAL_BUILDER_IMAGE_DOCKER_BUILDX_CACHE_WRITE_VERSION" {
  default = "type=local,mode=max,dest=${LOCAL_BUILDER_IMAGE_DOCKER_BUILDX_LOCAL_CACHE_VERSION}"
}


variable "LOCAL_BUILDER_IMAGE_DOCKER_BUILDX_CACHE_READ_VERSION" {
  default = "type=local,src=${LOCAL_BUILDER_IMAGE_DOCKER_BUILDX_LOCAL_CACHE_VERSION}"
}

variable "LOCAL_BUILDER_IMAGE_DOCKER_BUILDX_CACHE_WRITE_LATEST" {
  default = "type=local,mode=max,dest=${LOCAL_BUILDER_IMAGE_DOCKER_BUILDX_LOCAL_CACHE_LATEST}"
}

variable "LOCAL_BUILDER_IMAGE_DOCKER_BUILDX_CACHE_READ_LATEST" {
  default = "type=local,src=${LOCAL_BUILDER_IMAGE_DOCKER_BUILDX_LOCAL_CACHE_LATEST}"
}

variable "LOCAL_BUILDER_IMAGE_VERSION" {
  default = "${VEGITO_LOCAL_PUBLIC_IMAGES_BASE_NAME}:builder-${VERSION}"
}

variable "LOCAL_BUILDER_IMAGE_LATEST" {
  default = "${VEGITO_LOCAL_PUBLIC_IMAGES_BASE_NAME}:builder-latest"
}

target "local-project-builder-base" {
  dockerfile = "dev.Dockerfile"
  context    = LOCAL_DIR
  contexts = {
    debian = VEGITO_DOCKER_DEBIAN_PROJECT_GOLANG_CONTEXT
  }
  args = {
    debian_version = "trixie"
  }
}

target "local-project-builder" {
  inherits = ["local-project-builder-base"]
  tags = [
    LOCAL_BUILDER_IMAGE_VERSION,
    LOCAL_BUILDER_IMAGE_LATEST
  ]
  cache-from = concat(
    USE_REGISTRY_CACHE ? [
      "type=registry,ref=${LOCAL_BUILDER_IMAGE_REGISTRY_CACHE_CI}"
    ] : [],
    ENABLE_LOCAL_CACHE ? [
      LOCAL_BUILDER_IMAGE_DOCKER_BUILDX_CACHE_READ_LATEST
    ] : [],
    [
      "type=inline,ref=${LOCAL_BUILDER_IMAGE_LATEST}"
    ]
  )
  cache-to = concat(
    USE_REGISTRY_CACHE ? [
      "type=registry,ref=${LOCAL_BUILDER_IMAGE_REGISTRY_CACHE_CI},mode=max"
    ] : [],
    ENABLE_LOCAL_CACHE ? [
      LOCAL_BUILDER_IMAGE_DOCKER_BUILDX_CACHE_WRITE_LATEST
    ] : []
  )
}

group "local-project-builder-ci" {
  targets = [
    "local-project-builder-version-ci",
    "local-project-builder-latest-ci",
  ]
}

target "local-project-builder-version-ci" {
  inherits = ["local-project-builder-base"]
  tags = [
    LOCAL_BUILDER_IMAGE_VERSION
  ]
  cache-from = concat(
    USE_REGISTRY_CACHE ? [
      "type=registry,ref=${LOCAL_BUILDER_IMAGE_REGISTRY_CACHE_CI}"
    ] : [],
    ENABLE_LOCAL_CACHE ? [
      LOCAL_BUILDER_IMAGE_DOCKER_BUILDX_CACHE_READ_VERSION
    ] : [],
    [
      "type=inline,ref=${LOCAL_BUILDER_IMAGE_LATEST}"
    ]
  )
  cache-to = concat(
    ENABLE_LOCAL_CACHE ? [
      LOCAL_BUILDER_IMAGE_DOCKER_BUILDX_CACHE_WRITE_VERSION
    ] : []
  )

}

target "local-project-builder-latest-ci" {
  inherits = ["local-project-builder-base"]
  tags = [
    VEGITO_LOCAL_PUBLIC_IMAGES_BASE_NAME
  ]
  cache-from = concat(
    USE_REGISTRY_CACHE ? [
      "type=registry,ref=${LOCAL_BUILDER_IMAGE_REGISTRY_CACHE_CI}"
    ] : [],
    ENABLE_LOCAL_CACHE ? [
      LOCAL_BUILDER_IMAGE_DOCKER_BUILDX_CACHE_READ_LATEST
    ] : [],
    [
      "type=inline,ref=${LOCAL_BUILDER_IMAGE_LATEST}"
    ]
  )
  cache-to = concat(
    USE_REGISTRY_CACHE ? [
      "type=registry,ref=${LOCAL_BUILDER_IMAGE_REGISTRY_CACHE_CI},mode=max"
    ] : [],
    ENABLE_LOCAL_CACHE ? [
      LOCAL_BUILDER_IMAGE_DOCKER_BUILDX_CACHE_WRITE_LATEST
    ] : []
  )
  platforms = platforms
}
