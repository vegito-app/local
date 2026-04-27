variable "VEGITO_EXAMPLE_APPLICATION_BACKEND_DIR" {
  description = "current git tag or commit version"
  default     = "${VEGITO_EXAMPLE_APPLICATION_DIR}/backend"
}

variable "VEGITO_EXAMPLE_APPLICATION_BACKEND_IMAGES_BASE" {
  default = "${VEGITO_EXAMPLE_APPLICATION_PUBLIC_IMAGES_BASE}:backend"
}

variable "VEGITO_EXAMPLE_APPLICATION_BACKEND_IMAGE_VERSION" {
  default = "${VEGITO_EXAMPLE_APPLICATION_BACKEND_IMAGES_BASE}-${VERSION}"
}

variable "VEGITO_EXAMPLE_APPLICATION_BACKEND_IMAGE_LATEST" {
  default = "${VEGITO_EXAMPLE_APPLICATION_BACKEND_IMAGES_BASE}-latest"
}

variable "VEGITO_EXAMPLE_APPLICATION_BACKEND_IMAGE_REGISTRY_CACHE" {
  default = "${VEGITO_EXAMPLE_APPLICATION_CACHE_IMAGES_BASE}/backend"
}

variable "VEGITO_EXAMPLE_APPLICATION_BACKEND_DOCKER_BUILDX_LOCAL_CACHE_VERSION" {
  default = "${LOCAL_DOCKER_BUILDX_LOCAL_CACHE_DIR}/example-application-backend-version"
}

variable "VEGITO_EXAMPLE_APPLICATION_BACKEND_DOCKER_BUILDX_LOCAL_CACHE_LATEST" {
  default = "${LOCAL_DOCKER_BUILDX_LOCAL_CACHE_DIR}/example-application-backend-latest"
}

variable "VEGITO_EXAMPLE_APPLICATION_BACKEND_IMAGE_DOCKER_BUILDX_LOCAL_CACHE_VERSION" {
  default = "${VEGITO_EXAMPLE_APPLICATION_BACKEND_DOCKER_BUILDX_LOCAL_CACHE_VERSION}/backend"
}

variable "VEGITO_EXAMPLE_APPLICATION_BACKEND_IMAGE_DOCKER_BUILDX_LOCAL_CACHE_LATEST" {
  default = "${VEGITO_EXAMPLE_APPLICATION_BACKEND_DOCKER_BUILDX_LOCAL_CACHE_LATEST}/backend"
}

variable "VEGITO_EXAMPLE_APPLICATION_BACKEND_IMAGE_DOCKER_BUILDX_CACHE_WRITE_VERSION" {
  description = "local write cache (version) for example-application-backend image build"
  default     = "type=local,mode=max,dest=${VEGITO_EXAMPLE_APPLICATION_BACKEND_IMAGE_DOCKER_BUILDX_LOCAL_CACHE_VERSION}"
}

variable "VEGITO_EXAMPLE_APPLICATION_BACKEND_IMAGE_DOCKER_BUILDX_CACHE_WRITE_LATEST" {
  description = "local write cache (latest) for example-application-backend image build"
  default     = "type=local,mode=max,dest=${VEGITO_EXAMPLE_APPLICATION_BACKEND_IMAGE_DOCKER_BUILDX_LOCAL_CACHE_LATEST}"
}

variable "VEGITO_EXAMPLE_APPLICATION_BACKEND_IMAGE_DOCKER_BUILDX_LOCAL_CACHE_READ_VERSION" {
  description = "local read cache (version) for example-application-backend image build (cannot be used before first write)"
  default     = "type=local,src=${VEGITO_EXAMPLE_APPLICATION_BACKEND_IMAGE_DOCKER_BUILDX_LOCAL_CACHE_VERSION}"
}

variable "VEGITO_EXAMPLE_APPLICATION_BACKEND_IMAGE_DOCKER_BUILDX_LOCAL_CACHE_READ_LATEST" {
  description = "local read cache (latest) for example-application-backend image build (cannot be used before first write)"
  default     = "type=local,src=${VEGITO_EXAMPLE_APPLICATION_BACKEND_IMAGE_DOCKER_BUILDX_LOCAL_CACHE_LATEST}"
}

variable "VEGITO_EXAMPLE_APPLICATION_BACKEND_BUILDER_VERSION_CONTEXT_CI" {
  default = "target:vegito-example-application-builder-version-ci"
}

variable "VEGITO_EXAMPLE_APPLICATION_BACKEND_BUILDER_LATEST_CONTEXT_CI" {
  default = "target:vegito-example-application-builder-latest-ci"
}

variable "VEGITO_EXAMPLE_APPLICATION_BACKEND_BUILDER_CONTEXT" {
  default = "target:vegito-example-application-builder"
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
    gobuilder   = VEGITO_EXAMPLE_APPLICATION_BACKEND_BUILDER_VERSION_CONTEXT_CI
  }
  tags = [
    VEGITO_EXAMPLE_APPLICATION_BACKEND_IMAGE_VERSION,
  ]
  cache-from = concat(
    USE_REGISTRY_CACHE ? [
      "type=registry,ref=${VEGITO_EXAMPLE_APPLICATION_BACKEND_IMAGE_REGISTRY_CACHE}"
    ] : [],
    ENABLE_LOCAL_CACHE ? [
      VEGITO_EXAMPLE_APPLICATION_BACKEND_IMAGE_DOCKER_BUILDX_LOCAL_CACHE_READ_VERSION
    ] : [],
    [
      "type=inline,ref=${VEGITO_EXAMPLE_APPLICATION_BACKEND_IMAGE_LATEST}"
    ]
  )
  cache-to = concat(
    ENABLE_LOCAL_CACHE ? [
      VEGITO_EXAMPLE_APPLICATION_BACKEND_IMAGE_DOCKER_BUILDX_CACHE_WRITE_VERSION
    ] : []
  )
  platforms = [
    "linux/amd64"
  ]
  push = true
}

target "vegito-example-application-backend-latest-ci" {
  context = VEGITO_EXAMPLE_APPLICATION_BACKEND_DIR
  contexts = {
    approot     = VEGITO_EXAMPLE_APPLICATION_DIR
    appfrontend = "${VEGITO_EXAMPLE_APPLICATION_DIR}/frontend"
    local       = LOCAL_DIR
    gobuilder   = VEGITO_EXAMPLE_APPLICATION_BACKEND_BUILDER_LATEST_CONTEXT_CI
  }
  tags = [
    VEGITO_EXAMPLE_APPLICATION_BACKEND_IMAGE_LATEST,
  ]
  cache-from = concat(
    USE_REGISTRY_CACHE ? [
      "type=registry,ref=${VEGITO_EXAMPLE_APPLICATION_BACKEND_IMAGE_REGISTRY_CACHE}"
    ] : [],
    ENABLE_LOCAL_CACHE ? [
      VEGITO_EXAMPLE_APPLICATION_BACKEND_IMAGE_DOCKER_BUILDX_LOCAL_CACHE_READ_LATEST
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
      VEGITO_EXAMPLE_APPLICATION_BACKEND_IMAGE_DOCKER_BUILDX_CACHE_WRITE_LATEST
    ] : [],
    [
      "type=inline"
    ]
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
    gobuilder   = VEGITO_EXAMPLE_APPLICATION_BACKEND_BUILDER_CONTEXT
  }
  tags = [
    VEGITO_EXAMPLE_APPLICATION_BACKEND_IMAGE_VERSION,
    VEGITO_EXAMPLE_APPLICATION_BACKEND_IMAGE_LATEST,
  ]
  cache-from = concat(
    USE_REGISTRY_CACHE ? [
      "type=registry,ref=${VEGITO_EXAMPLE_APPLICATION_BACKEND_IMAGE_REGISTRY_CACHE}"
    ] : [],
    ENABLE_LOCAL_CACHE ? [
      VEGITO_EXAMPLE_APPLICATION_BACKEND_IMAGE_DOCKER_BUILDX_LOCAL_CACHE_READ_LATEST
    ] : [],
    [
      "type=inline,ref=${VEGITO_EXAMPLE_APPLICATION_BACKEND_IMAGE_LATEST}"
    ]
  )
  cache-to = concat(
    ENABLE_LOCAL_CACHE ? [
      VEGITO_EXAMPLE_APPLICATION_BACKEND_IMAGE_DOCKER_BUILDX_CACHE_WRITE_LATEST
    ] : []
  )
}
