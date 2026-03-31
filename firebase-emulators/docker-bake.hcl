variable "LOCAL_FIREBASE_EMULATORS_IMAGE_VERSION" {
  default = notequal("", VERSION) ? "${VEGITO_LOCAL_PUBLIC_IMAGES_BASE}:firebase-emulators-${VERSION}" : ""
}

variable "LOCAL_FIREBASE_EMULATORS_IMAGE_LATEST" {
  default = "${VEGITO_LOCAL_PUBLIC_IMAGES_BASE}:firebase-emulators-latest"
}

variable "LOCAL_FIREBASE_EMULATORS_IMAGE_REGISTRY_CACHE" {
  default = "${VEGITO_LOCAL_CACHE_IMAGES_BASE}/cache/firebase-emulators"
}

variable "LOCAL_FIREBASE_EMULATORS_IMAGE_DOCKER_BUILDX_LOCAL_CACHE" {
  default = "${LOCAL_DOCKER_BUILDX_LOCAL_CACHE_DIR}/firebase-emulators"
}

variable "LOCAL_FIREBASE_EMULATORS_IMAGE_DOCKER_BUILDX_LOCAL_CACHE_WRITE" {
  description = "local write cache for firebase emulators image build"
  default     = "type=local,mode=max,dest=${LOCAL_FIREBASE_EMULATORS_IMAGE_DOCKER_BUILDX_LOCAL_CACHE}"
}

variable "LOCAL_FIREBASE_EMULATORS_IMAGE_DOCKER_BUILDX_LOCAL_CACHE_READ" {
  description = "local read cache for firebase emulators image build (cannot be used before first write)"
  default     = "type=local,src=${LOCAL_FIREBASE_EMULATORS_IMAGE_DOCKER_BUILDX_LOCAL_CACHE}"
}

target "local-firebase-emulators-ci" {
  contexts = {
    builder_image = "target:local-project-builder-version-ci"
    debian_image  = "target:local-debian-version-ci"
  }
  context = "${LOCAL_DIR}/firebase-emulators"
  tags = [
    LOCAL_FIREBASE_EMULATORS_IMAGE_VERSION,
  ]
  cache-from = concat(
    USE_REGISTRY_CACHE ? [
      "type=registry,ref=${LOCAL_FIREBASE_EMULATORS_IMAGE_REGISTRY_CACHE}"
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
  cache-to  = []
  platforms = platforms
}

target "local-firebase-emulators-latest-ci" {
  contexts = {
    builder_image = "target:local-project-builder-latest-ci"
    debian_image  = "target:local-debian-latest-ci"
  }
  context = "${LOCAL_DIR}/firebase-emulators"
  tags = [
    LOCAL_FIREBASE_EMULATORS_IMAGE_LATEST,
  ]
  cache-from = concat(
    USE_REGISTRY_CACHE ? [
      "type=registry,ref=${LOCAL_FIREBASE_EMULATORS_IMAGE_REGISTRY_CACHE}"
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
  cache-to = [
    USE_REGISTRY_CACHE ? "type=registry,ref=${LOCAL_FIREBASE_EMULATORS_IMAGE_REGISTRY_CACHE},mode=max" : "type=inline"
  ]
  platforms = platforms
}

target "local-firebase-emulators" {
  contexts = {
    builder_image = "target:local-project-builder"
    debian_image  = "target:local-debian"
  }
  context = "${LOCAL_DIR}/firebase-emulators"
  tags = [
    LOCAL_FIREBASE_EMULATORS_IMAGE_LATEST,
    LOCAL_FIREBASE_EMULATORS_IMAGE_VERSION,
  ]
  cache-from = concat(
    ENABLE_LOCAL_CACHE ? [
      LOCAL_FIREBASE_EMULATORS_IMAGE_DOCKER_BUILDX_LOCAL_CACHE_READ
    ] : [],
    USE_REGISTRY_CACHE ? [
      "type=registry,ref=${LOCAL_FIREBASE_EMULATORS_IMAGE_REGISTRY_CACHE}"
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
      LOCAL_FIREBASE_EMULATORS_IMAGE_DOCKER_BUILDX_LOCAL_CACHE_WRITE
    ] : []
  )
}
