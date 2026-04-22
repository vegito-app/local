variable "LOCAL_FIREBASE_EMULATORS_IMAGE_VERSION" {
  default = "${VEGITO_LOCAL_PUBLIC_IMAGES_BASE}:firebase-emulators-${VERSION}"
}

variable "LOCAL_FIREBASE_EMULATORS_IMAGE_LATEST" {
  default = "${VEGITO_LOCAL_PUBLIC_IMAGES_BASE}:firebase-emulators-latest"
}

variable "LOCAL_FIREBASE_EMULATORS_IMAGE_REGISTRY_CACHE" {
  default = "${VEGITO_LOCAL_CACHE_IMAGES_BASE}/cache/firebase-emulators"
}

variable "LOCAL_FIREBASE_EMULATORS_IMAGE_DOCKER_BUILDX_LOCAL_CACHE_VERSION" {
  default = "${LOCAL_DOCKER_BUILDX_LOCAL_CACHE_DIR}/firebase-emulators-version"
}

variable "LOCAL_FIREBASE_EMULATORS_IMAGE_DOCKER_BUILDX_LOCAL_CACHE_LATEST" {
  default = "${LOCAL_DOCKER_BUILDX_LOCAL_CACHE_DIR}/firebase-emulators-latest"
}

variable "LOCAL_FIREBASE_EMULATORS_IMAGE_DOCKER_BUILDX_CACHE_WRITE_VERSION" {
  description = "local write cache (version)"
  default     = "type=local,mode=max,dest=${LOCAL_FIREBASE_EMULATORS_IMAGE_DOCKER_BUILDX_LOCAL_CACHE_VERSION}"
}

variable "LOCAL_FIREBASE_EMULATORS_IMAGE_DOCKER_BUILDX_CACHE_WRITE_LATEST" {
  description = "local write cache (latest)"
  default     = "type=local,mode=max,dest=${LOCAL_FIREBASE_EMULATORS_IMAGE_DOCKER_BUILDX_LOCAL_CACHE_LATEST}"
}

variable "LOCAL_FIREBASE_EMULATORS_IMAGE_DOCKER_BUILDX_LOCAL_CACHE_READ_VERSION" {
  description = "local read cache (version)"
  default     = "type=local,src=${LOCAL_FIREBASE_EMULATORS_IMAGE_DOCKER_BUILDX_LOCAL_CACHE_VERSION}"
}

variable "LOCAL_FIREBASE_EMULATORS_IMAGE_DOCKER_BUILDX_LOCAL_CACHE_READ_LATEST" {
  description = "local read cache (latest)"
  default     = "type=local,src=${LOCAL_FIREBASE_EMULATORS_IMAGE_DOCKER_BUILDX_LOCAL_CACHE_LATEST}"
}

group "local-firebase-emulators-ci" {
  targets = [
    "local-firebase-emulators-version-ci",
    "local-firebase-emulators-latest-ci",
  ]
}

target "local-firebase-emulators-version-ci" {
  contexts = {
    builder_image = "target:local-project-builder-version-ci"
    debian_image  = "docker-image://${LOCAL_DEBIAN_IMAGE_VERSION}"
  }
  context = "${LOCAL_DIR}/firebase-emulators"
  tags = [
    LOCAL_FIREBASE_EMULATORS_IMAGE_VERSION,
  ]
  cache-from = concat(
    USE_REGISTRY_CACHE ? [
      "type=registry,ref=${LOCAL_FIREBASE_EMULATORS_IMAGE_REGISTRY_CACHE}"
    ] : [],
    ENABLE_LOCAL_CACHE ? [
      LOCAL_FIREBASE_EMULATORS_IMAGE_DOCKER_BUILDX_LOCAL_CACHE_READ_VERSION
    ] : [],
    ENABLE_LOCAL_CACHE ? [
      LOCAL_FIREBASE_EMULATORS_IMAGE_DOCKER_BUILDX_LOCAL_CACHE_READ_VERSION
    ] : [],
    USE_REGISTRY_CACHE ? [
      "type=registry,ref=${LOCAL_BUILDER_IMAGE_REGISTRY_CACHE}"
    ] : [],
    [
      "type=inline,ref=${LOCAL_FIREBASE_EMULATORS_IMAGE_LATEST}",
      "type=inline,ref=${LOCAL_BUILDER_IMAGE_LATEST}",
      "type=inline,ref=${LOCAL_DEBIAN_IMAGE_LATEST}"
    ]
  )
  cache-to = concat(
    ENABLE_LOCAL_CACHE ? [
      LOCAL_FIREBASE_EMULATORS_IMAGE_DOCKER_BUILDX_CACHE_WRITE_VERSION
    ] : [],
  )
  platforms = platforms
}

target "local-firebase-emulators-latest-ci" {
  contexts = {
    builder_image = "target:local-project-builder-latest-ci"
    debian_image  = "docker-image://${LOCAL_DEBIAN_IMAGE_LATEST}"
  }
  context = "${LOCAL_DIR}/firebase-emulators"
  tags = [
    LOCAL_FIREBASE_EMULATORS_IMAGE_LATEST,
  ]
  cache-from = concat(
    USE_REGISTRY_CACHE ? [
      "type=registry,ref=${LOCAL_FIREBASE_EMULATORS_IMAGE_REGISTRY_CACHE}"
    ] : [],
    ENABLE_LOCAL_CACHE ? [
      LOCAL_FIREBASE_EMULATORS_IMAGE_DOCKER_BUILDX_LOCAL_CACHE_READ_LATEST
    ] : [],
    USE_REGISTRY_CACHE ? [
      "type=registry,ref=${LOCAL_BUILDER_IMAGE_REGISTRY_CACHE}"
    ] : [],
    [
      "type=inline,ref=${LOCAL_FIREBASE_EMULATORS_IMAGE_LATEST}",
      "type=inline,ref=${LOCAL_BUILDER_IMAGE_LATEST}",
      "type=inline,ref=${LOCAL_DEBIAN_IMAGE_LATEST}"
    ]
  )
  cache-to = concat(
    USE_REGISTRY_CACHE ? [
      "type=registry,ref=${LOCAL_FIREBASE_EMULATORS_IMAGE_REGISTRY_CACHE},mode=max"
    ] : [],
    ENABLE_LOCAL_CACHE ? [
      LOCAL_FIREBASE_EMULATORS_IMAGE_DOCKER_BUILDX_CACHE_WRITE_LATEST
    ] : [],
    [
      "type=inline"
    ]
  )
  platforms = platforms
}

target "local-firebase-emulators" {
  contexts = {
    builder_image = "target:local-project-builder"
    debian_image  = "docker-image://${LOCAL_DEBIAN_IMAGE_VERSION}"
  }
  context = "${LOCAL_DIR}/firebase-emulators"
  tags = [
    LOCAL_FIREBASE_EMULATORS_IMAGE_LATEST,
    LOCAL_FIREBASE_EMULATORS_IMAGE_VERSION,
  ]
  cache-from = concat(
    USE_REGISTRY_CACHE ? [
      "type=registry,ref=${LOCAL_FIREBASE_EMULATORS_IMAGE_REGISTRY_CACHE}"
    ] : [],
    ENABLE_LOCAL_CACHE ? [
      LOCAL_FIREBASE_EMULATORS_IMAGE_DOCKER_BUILDX_LOCAL_CACHE_READ_LATEST
    ] : [],
    USE_REGISTRY_CACHE ? [
      "type=registry,ref=${LOCAL_BUILDER_IMAGE_REGISTRY_CACHE}"
    ] : [],
    [
      "type=inline,ref=${LOCAL_FIREBASE_EMULATORS_IMAGE_LATEST}",
      "type=inline,ref=${LOCAL_BUILDER_IMAGE_LATEST}",
      "type=inline,ref=${LOCAL_DEBIAN_IMAGE_LATEST}"
    ]
  )
  cache-to = concat(
    ENABLE_LOCAL_CACHE ? [
      LOCAL_FIREBASE_EMULATORS_IMAGE_DOCKER_BUILDX_CACHE_WRITE_LATEST
    ] : []
  )
}
