variable "LOCAL_ROBOTFRAMEWORK_TESTS_IMAGES_BASE" {
  default = "${VEGITO_LOCAL_PUBLIC_IMAGES_BASE_NAME}:robotframework"
}

variable "LOCAL_ROBOTFRAMEWORK_IMAGE_VERSION" {
  default = "${VEGITO_LOCAL_PUBLIC_IMAGES_BASE_NAME}:robotframework-${VERSION}"
}

variable "LOCAL_ROBOTFRAMEWORK_TESTS_IMAGE_LATEST" {
  default = "${LOCAL_ROBOTFRAMEWORK_TESTS_IMAGES_BASE}-latest"
}

variable "LOCAL_ROBOTFRAMEWORK_TESTS_IMAGE_REGISTRY_CACHE" {
  default = "${VEGITO_LOCAL_CACHE_IMAGES_BASE}/robotframework"
}

variable "LOCAL_ROBOTFRAMEWORK_IMAGE_DOCKER_BUILDX_LOCAL_CACHE_VERSION" {
  default = "${LOCAL_DOCKER_BUILDX_LOCAL_CACHE_DIR}/robotframework-version"
}

variable "LOCAL_ROBOTFRAMEWORK_IMAGE_DOCKER_BUILDX_LOCAL_CACHE_LATEST" {
  default = "${LOCAL_DOCKER_BUILDX_LOCAL_CACHE_DIR}/robotframework-latest"
}

variable "LOCAL_ROBOTFRAMEWORK_IMAGE_DOCKER_BUILDX_CACHE_WRITE_VERSION" {
  description = "local write cache for clarinet image build (version)"
  default     = "type=local,mode=max,dest=${LOCAL_ROBOTFRAMEWORK_IMAGE_DOCKER_BUILDX_LOCAL_CACHE_VERSION}"
}

variable "LOCAL_ROBOTFRAMEWORK_IMAGE_DOCKER_BUILDX_CACHE_WRITE_LATEST" {
  description = "local write cache for clarinet image build (latest)"
  default     = "type=local,mode=max,dest=${LOCAL_ROBOTFRAMEWORK_IMAGE_DOCKER_BUILDX_LOCAL_CACHE_LATEST}"
}

variable "LOCAL_ROBOTFRAMEWORK_IMAGE_DOCKER_BUILDX_LOCAL_CACHE_READ_VERSION" {
  description = "local read cache for clarinet image build (version)"
  default     = "type=local,src=${LOCAL_ROBOTFRAMEWORK_IMAGE_DOCKER_BUILDX_LOCAL_CACHE_VERSION}"
}

variable "LOCAL_ROBOTFRAMEWORK_IMAGE_DOCKER_BUILDX_LOCAL_CACHE_READ_LATEST" {
  description = "local read cache for clarinet image build (latest)"
  default     = "type=local,src=${LOCAL_ROBOTFRAMEWORK_IMAGE_DOCKER_BUILDX_LOCAL_CACHE_LATEST}"
}

group "local-robotframework-ci" {
  targets = [
    "local-robotframework-version-ci",
    "local-robotframework-latest-ci",
  ]
}

target "local-robotframework-version-ci" {
  contexts = {
    debian_image = "docker-image://${LOCAL_DEBIAN_IMAGE_VERSION}"
  }
  context    = "${LOCAL_DIR}/robotframework"
  dockerfile = "Dockerfile"
  tags = [
    LOCAL_ROBOTFRAMEWORK_IMAGE_VERSION,
  ]
  cache-from = concat(
    USE_REGISTRY_CACHE ? [
      "type=registry,ref=${LOCAL_ROBOTFRAMEWORK_TESTS_IMAGE_REGISTRY_CACHE}"
    ] : [],
    ENABLE_LOCAL_CACHE ? [
      LOCAL_ROBOTFRAMEWORK_IMAGE_DOCKER_BUILDX_LOCAL_CACHE_READ_VERSION
    ] : [],
    ENABLE_LOCAL_CACHE ? [
      LOCAL_ROBOTFRAMEWORK_IMAGE_DOCKER_BUILDX_LOCAL_CACHE_READ_VERSION
    ] : [],
    [
      "type=inline,ref=${LOCAL_ROBOTFRAMEWORK_TESTS_IMAGE_LATEST}"
    ]
  )
  cache-to = concat(
    ENABLE_LOCAL_CACHE ? [
      LOCAL_ROBOTFRAMEWORK_IMAGE_DOCKER_BUILDX_CACHE_WRITE_VERSION
    ] : [],
  )
  platforms = platforms
}

target "local-robotframework-latest-ci" {
  contexts = {
    debian_image = "docker-image://${LOCAL_DEBIAN_IMAGE_LATEST}"
  }
  context    = "${LOCAL_DIR}/robotframework"
  dockerfile = "Dockerfile"
  tags = [
    LOCAL_ROBOTFRAMEWORK_TESTS_IMAGE_LATEST,
  ]
  cache-from = concat(
    USE_REGISTRY_CACHE ? [
      "type=registry,ref=${LOCAL_ROBOTFRAMEWORK_TESTS_IMAGE_REGISTRY_CACHE}"
    ] : [],
    ENABLE_LOCAL_CACHE ? [
      LOCAL_ROBOTFRAMEWORK_IMAGE_DOCKER_BUILDX_LOCAL_CACHE_READ_LATEST
    ] : [],
    [
      "type=inline,ref=${LOCAL_ROBOTFRAMEWORK_TESTS_IMAGE_LATEST}"
    ]
  )
  cache-to = concat(
    USE_REGISTRY_CACHE ? [
      "type=registry,ref=${LOCAL_ROBOTFRAMEWORK_TESTS_IMAGE_REGISTRY_CACHE},mode=max"
    ] : [],
    ENABLE_LOCAL_CACHE ? [
      LOCAL_ROBOTFRAMEWORK_IMAGE_DOCKER_BUILDX_CACHE_WRITE_LATEST
    ] : [],
    [
      "type=inline"
    ]
  )
  platforms = platforms
}

target "local-robotframework" {
  context    = "${LOCAL_DIR}/robotframework"
  dockerfile = "Dockerfile"
  contexts = {
    debian_image = "docker-image://${LOCAL_DEBIAN_IMAGE_VERSION}"
  }
  tags = [
    LOCAL_ROBOTFRAMEWORK_IMAGE_VERSION,
    LOCAL_ROBOTFRAMEWORK_TESTS_IMAGE_LATEST,
  ]
  cache-from = concat(
    USE_REGISTRY_CACHE ? [
      "type=registry,ref=${LOCAL_ROBOTFRAMEWORK_TESTS_IMAGE_REGISTRY_CACHE}"
    ] : [],
    ENABLE_LOCAL_CACHE ? [
      LOCAL_ROBOTFRAMEWORK_IMAGE_DOCKER_BUILDX_LOCAL_CACHE_READ_LATEST
    ] : [],
    [
      "type=inline,ref=${LOCAL_ROBOTFRAMEWORK_TESTS_IMAGE_LATEST}"
    ]
  )
  cache-to = concat(
    ENABLE_LOCAL_CACHE ? [
      LOCAL_ROBOTFRAMEWORK_IMAGE_DOCKER_BUILDX_CACHE_WRITE_LATEST
    ] : []
  )
}
