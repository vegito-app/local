variable "VEGITO_EXAMPLE_APPLICATION_BACKEND_DIR" {
  description = "current git tag or commit version"
  default     = "${VEGITO_EXAMPLE_APPLICATION_DIR}/backend"
}

variable "VERSION" {
  description = "current git tag or commit version"
  default     = "dev"
}

variable "VEGITO_EXAMPLE_APPLICATION_BACKEND_IMAGES_BASE" {
  default = "${VEGITO_EXAMPLE_APPLICATION_PUBLIC_IMAGES_BASE}:backend"
}

variable "VEGITO_EXAMPLE_APPLICATION_BACKEND_IMAGE" {
  default = "${VEGITO_EXAMPLE_APPLICATION_BACKEND_IMAGES_BASE}-${VERSION}"
}

variable "VEGITO_EXAMPLE_APPLICATION_BACKEND_IMAGE_LATEST" {
  default = "${VEGITO_EXAMPLE_APPLICATION_BACKEND_IMAGES_BASE}-latest"
}

variable "VEGITO_EXAMPLE_APPLICATION_BACKEND_IMAGE_REGISTRY_CACHE" {
  default = "${VEGITO_EXAMPLE_APPLICATION_CACHE_IMAGES_BASE}/backend"
}

variable "VEGITO_EXAMPLE_APPLICATION_BACKEND_DOCKER_BUILDX_LOCAL_CACHE_DIR" {
  default = "${LOCAL_DOCKER_BUILDX_LOCAL_CACHE_DIR}/example-application-backend"
}

variable "VEGITO_EXAMPLE_APPLICATION_BACKEND_IMAGE_DOCKER_BUILDX_LOCAL_CACHE" {
  default = "${VEGITO_EXAMPLE_APPLICATION_BACKEND_DOCKER_BUILDX_LOCAL_CACHE_DIR}/backend"
}

variable "VEGITO_EXAMPLE_APPLICATION_BACKEND_IMAGE_DOCKER_BUILDX_CACHE_WRITE" {
  description = "local write cache for example-application-backend image build"
  default     = "type=local,mode=max,dest=${VEGITO_EXAMPLE_APPLICATION_BACKEND_IMAGE_DOCKER_BUILDX_LOCAL_CACHE}"
}

variable "VEGITO_EXAMPLE_APPLICATION_BACKEND_IMAGE_DOCKER_BUILDX_LOCAL_CACHE_READ" {
  description = "local read cache for example-application-backend image build (cannot be used before first write)"
  default     = "type=local,src=${VEGITO_EXAMPLE_APPLICATION_BACKEND_IMAGE_DOCKER_BUILDX_LOCAL_CACHE}"
}

variable "VEGITO_EXAMPLE_APPLICATION_BACKEND_BUILDER_CONTEXT_CI" {
  default = "target:vegito-example-application-builder-version-ci"
}

group "vegito-example-application-backend-ci" {
  targets = [
    "vegito-example-application-backend-version-ci",
    "vegito-example-application-backend-latest-ci",
  ]
}

target "vegito-example-application-backend-version-ci" {
  context = VEGITO_EXAMPLE_APPLICATION_BACKEND_DIR
  contexts = {
    approot     = VEGITO_EXAMPLE_APPLICATION_DIR
    appfrontend = "${VEGITO_EXAMPLE_APPLICATION_DIR}/frontend"
    local       = LOCAL_DIR
    gobuilder   = VEGITO_EXAMPLE_APPLICATION_BACKEND_BUILDER_CONTEXT_CI
  }
  tags = [
    VEGITO_EXAMPLE_APPLICATION_BACKEND_IMAGE,
  ]
  cache-from = concat(
    USE_REGISTRY_CACHE ? [
      "type=registry,ref=${VEGITO_EXAMPLE_APPLICATION_BACKEND_IMAGE_REGISTRY_CACHE}"
    ] : [],
    ENABLE_LOCAL_CACHE ? [
      VEGITO_EXAMPLE_APPLICATION_BACKEND_IMAGE_DOCKER_BUILDX_LOCAL_CACHE_READ
    ] : [],
    [
      "type=inline,ref=${VEGITO_EXAMPLE_APPLICATION_BACKEND_IMAGE_LATEST}"
    ]
  )
  cache-to = concat(
    ENABLE_LOCAL_CACHE ? [
      VEGITO_EXAMPLE_APPLICATION_BACKEND_IMAGE_DOCKER_BUILDX_CACHE_WRITE
    ] : [],
  )
  platforms = [
    "linux/amd64",
  ]
  push = true
}

target "vegito-example-application-backend-latest-ci" {
  context = VEGITO_EXAMPLE_APPLICATION_BACKEND_DIR
  contexts = {
    approot     = VEGITO_EXAMPLE_APPLICATION_DIR
    appfrontend = "${VEGITO_EXAMPLE_APPLICATION_DIR}/frontend"
    local       = LOCAL_DIR
    gobuilder   = VEGITO_EXAMPLE_APPLICATION_BACKEND_BUILDER_CONTEXT_CI
  }
  tags = [
    VEGITO_EXAMPLE_APPLICATION_BACKEND_IMAGE_LATEST,
  ]
  cache-from = concat(
    USE_REGISTRY_CACHE ? [
      "type=registry,ref=${VEGITO_EXAMPLE_APPLICATION_BACKEND_IMAGE_REGISTRY_CACHE}"
    ] : [],
    ENABLE_LOCAL_CACHE ? [
      VEGITO_EXAMPLE_APPLICATION_BACKEND_IMAGE_DOCKER_BUILDX_LOCAL_CACHE_READ
    ] : [],
    [
      "type=inline,ref=${VEGITO_EXAMPLE_APPLICATION_BACKEND_IMAGE_LATEST}"
    ]
  )
  cache-to = concat(
    USE_REGISTRY_CACHE ? [
      "type=registry,ref=${VEGITO_EXAMPLE_APPLICATION_BACKEND_IMAGE_REGISTRY_CACHE},mode=max"
    ] : [],
    ENABLE_LOCAL_CACHE ? [
      VEGITO_EXAMPLE_APPLICATION_BACKEND_IMAGE_DOCKER_BUILDX_CACHE_WRITE
    ] : []
  )
  platforms = [
    "linux/amd64",
  ]
  push = true
}

target "vegito-example-application-backend" {
  context = VEGITO_EXAMPLE_APPLICATION_BACKEND_DIR
  contexts = {
    approot     = VEGITO_EXAMPLE_APPLICATION_DIR
    appfrontend = "${VEGITO_EXAMPLE_APPLICATION_DIR}/frontend"
    local       = LOCAL_DIR
    gobuilder   = "docker-image://${EXAMPLE_APPLICATION_BUILDER_IMAGE_VERSION}"
  }
  tags = [
    VEGITO_EXAMPLE_APPLICATION_BACKEND_IMAGE,
    VEGITO_EXAMPLE_APPLICATION_BACKEND_IMAGE_LATEST,
  ]
  cache-from = concat(
    USE_REGISTRY_CACHE ? [
      "type=registry,ref=${VEGITO_EXAMPLE_APPLICATION_BACKEND_IMAGE_REGISTRY_CACHE}"
    ] : [],
    ENABLE_LOCAL_CACHE ? [
      VEGITO_EXAMPLE_APPLICATION_BACKEND_IMAGE_DOCKER_BUILDX_LOCAL_CACHE_READ
    ] : [],
    [
      "type=inline,ref=${VEGITO_EXAMPLE_APPLICATION_BACKEND_IMAGE_LATEST}"
    ]
  )
  cache-to = concat(
    USE_REGISTRY_CACHE ? [
      "type=registry,ref=${VEGITO_EXAMPLE_APPLICATION_BACKEND_IMAGE_REGISTRY_CACHE},mode=max"
    ] : [],
    ENABLE_LOCAL_CACHE ? [
      VEGITO_EXAMPLE_APPLICATION_BACKEND_IMAGE_DOCKER_BUILDX_CACHE_WRITE
    ] : []
  )
}
