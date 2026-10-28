variable "LOCAL_DIR" {
  default = "."
}

variable "VERSION" {
  description = "current git tag or commit version"
  default     = "local"
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

variable "LOCAL_DOCKER_PUBLIC_REGISTRY" {
  default = "registry-public.vegito.app"
}

variable "LOCAL_DOCKER_PUBLIC_REPOSITORY" {
  default = "${LOCAL_DOCKER_PUBLIC_REGISTRY}/vegito-app"
}

variable "LOCAL_DOCKER_PUBLIC_IMAGES_BASE_NAME" {
  default = "${LOCAL_DOCKER_PUBLIC_REPOSITORY}/vegito-local"
}

variable "LOCAL_DOCKER_CACHE_REGISTRY" {
  default = "registry-cache.vegito.app"
}

variable "LOCAL_DOCKER_CACHE_REPOSITORY" {
  default = "${LOCAL_DOCKER_CACHE_REGISTRY}/vegito-app"
}

variable "LOCAL_DOCKER_CACHE_IMAGES_BASE_NAME" {
  default = "${LOCAL_DOCKER_CACHE_REPOSITORY}/vegito-local"
}

variable "DEBIAN_VERSION_CODENAME" {
  default = "trixie"
}

variable "VEGITO_DOCKER_PUBLIC_IMAGES_VERSION" {
  description = "git@github.com:vegito-app/docker repository based images default version"
  default     = "latest"
}

variable "VEGITO_DOCKER_PRIVATE_REGISTRY" {
  default = "registry-private.vegito.app"
}

variable "VEGITO_DOCKER_PRIVATE_REPOSITORY" {
  default = "${VEGITO_DOCKER_PRIVATE_REGISTRY}/vegito-app"
}

variable "VEGITO_DOCKER_HUB_IMAGES_BASE_NAME" {
  default = "${VEGITO_DOCKER_PRIVATE_REPOSITORY}/dockerhub"
}

variable "VEGITO_DOCKER_PUBLIC_REGISTRY" {
  default = "registry-public.vegito.app"
}

variable "VEGITO_DOCKER_PUBLIC_REPOSITORY" {
  default = "${VEGITO_DOCKER_PUBLIC_REGISTRY}/vegito-app"
}

variable "VEGITO_DOCKER_PUBLIC_IMAGES_BASE_NAME" {
  default = "${VEGITO_DOCKER_PUBLIC_REPOSITORY}/vegito-docker"
}

variable "VEGITO_DOCKER_DEBIAN_CONTEXT" {
  default = "docker-image://${VEGITO_DOCKER_PUBLIC_IMAGES_BASE_NAME}:trixie-debian-${VEGITO_DOCKER_PUBLIC_IMAGES_VERSION}"
}

variable "VEGITO_DOCKER_DEBIAN_PROJECT_CONTEXT" {
  default = "docker-image://${VEGITO_DOCKER_PUBLIC_IMAGES_BASE_NAME}:trixie-debian-project-docker-${VEGITO_DOCKER_PUBLIC_IMAGES_VERSION}"
}

variable "VEGITO_DOCKER_DEBIAN_PROJECT_GOLANG_CONTEXT" {
  default = "docker-image://${VEGITO_DOCKER_PUBLIC_IMAGES_BASE_NAME}:trixie-debian-project-golang-docker-${VEGITO_DOCKER_PUBLIC_IMAGES_VERSION}"
}

variable "VEGITO_DOCKER_ALPINE_RUST_CONTEXT" {
  default = "docker-image://${VEGITO_DOCKER_HUB_IMAGES_BASE_NAME}/rust-alpine:${VEGITO_DOCKER_PUBLIC_IMAGES_VERSION}"
}

variable "VEGITO_DOCKER_DEBIAN_FLUTTER_DESKTOP_X_CONTEXT" {
  default = "docker-image://${VEGITO_DOCKER_PUBLIC_IMAGES_BASE_NAME}:trixie-debian-flutter-desktop-x-${VEGITO_DOCKER_PUBLIC_IMAGES_VERSION}"
}

variable "VEGITO_DOCKER_HUB_GOLANG_DEBIAN_CONTEXT" {
  default = "docker-image://${VEGITO_DOCKER_PUBLIC_IMAGES_BASE_NAME}:trixie-debian-project-${VEGITO_DOCKER_PUBLIC_IMAGES_VERSION}"
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

group "local-dev" {
  targets = [
    "local-project-builder-latest",
    "local-android",
    "local-clarinet-devnet",
    "local-firebase-emulators",
    "local-github-actions-runner",
    "local-robotframework",
    "local-vault-dev",
    "local-trivy",
  ]
}

group "local-dev-ci" {
  targets = [
    "local-project-builder-latest-ci",
    "local-android-ci",
    "local-clarinet-devnet-ci",
    "local-firebase-emulators-ci",
    "local-github-actions-runner-ci",
    "local-robotframework-ci",
    "local-vault-dev-ci",
    "local-trivy-ci",
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
    "local-dev",
    "vegito-example-application"
  ]
}

group "release-ci" {
  targets = [
    "local-dev-ci",
    "vegito-example-application-ci"
  ]
}

variable "LOCAL_BUILDER_IMAGES_BASE_NAME" {
  default = "${LOCAL_DOCKER_PUBLIC_IMAGES_BASE_NAME}:builder"
}

variable "LOCAL_BUILDER_IMAGE_VERSION" {
  default = "${LOCAL_BUILDER_IMAGES_BASE_NAME}-${VERSION}"
}

variable "LOCAL_BUILDER_IMAGE_LATEST" {
  default = "${LOCAL_BUILDER_IMAGES_BASE_NAME}-latest"
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
  default = "${LOCAL_DOCKER_CACHE_IMAGES_BASE_NAME}/builder"
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
      "type=registry,ref=${LOCAL_BUILDER_IMAGE_REGISTRY_CACHE}"
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
      "type=registry,ref=${LOCAL_BUILDER_IMAGE_REGISTRY_CACHE},mode=max"
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
      "type=registry,ref=${LOCAL_BUILDER_IMAGE_REGISTRY_CACHE}"
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
    LOCAL_BUILDER_IMAGE_LATEST
  ]
  cache-from = concat(
    USE_REGISTRY_CACHE ? [
      "type=registry,ref=${LOCAL_BUILDER_IMAGE_REGISTRY_CACHE}"
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
      "type=registry,ref=${LOCAL_BUILDER_IMAGE_REGISTRY_CACHE},mode=max"
    ] : [],
    ENABLE_LOCAL_CACHE ? [
      LOCAL_BUILDER_IMAGE_DOCKER_BUILDX_CACHE_WRITE_LATEST
    ] : []
  )
  platforms = platforms
}
