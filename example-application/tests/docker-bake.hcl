variable "VEGITO_EXAMPLE_APPLICATION_TESTS_DIR" {
  default = "${VEGITO_EXAMPLE_APPLICATION_DIR}/tests"
}

variable "VEGITO_EXAMPLE_APPLICATION_TESTS_IMAGES_BASE" {
  default = "${VEGITO_EXAMPLE_APPLICATION_PUBLIC_IMAGES_BASE}:tests"
}

variable "VEGITO_EXAMPLE_APPLICATION_TESTS_IMAGE" {
  default = "${VEGITO_EXAMPLE_APPLICATION_TESTS_IMAGES_BASE}-${VERSION}"
}

variable "VEGITO_EXAMPLE_APPLICATION_TESTS_IMAGE_LATEST" {
  default = "${VEGITO_EXAMPLE_APPLICATION_TESTS_IMAGES_BASE}-latest"
}

variable "VEGITO_EXAMPLE_APPLICATION_TESTS_IMAGE_REGISTRY_CACHE" {
  default = "${VEGITO_EXAMPLE_APPLICATION_CACHE_IMAGES_BASE}/tests"
}

variable "VEGITO_EXAMPLE_APPLICATION_TESTS_IMAGE_DOCKER_BUILDX_LOCAL_CACHE_VERSION" {
  default = "${LOCAL_DOCKER_BUILDX_LOCAL_CACHE_DIR}/example-application-tests-version"
}

variable "VEGITO_EXAMPLE_APPLICATION_TESTS_IMAGE_DOCKER_BUILDX_LOCAL_CACHE_LATEST" {
  default = "${LOCAL_DOCKER_BUILDX_LOCAL_CACHE_DIR}/example-application-tests-latest"
}

variable "VEGITO_EXAMPLE_APPLICATION_TESTS_IMAGE_DOCKER_BUILDX_CACHE_WRITE_VERSION" {
  description = "local write cache (version)"
  default     = "type=local,mode=max,dest=${VEGITO_EXAMPLE_APPLICATION_TESTS_IMAGE_DOCKER_BUILDX_LOCAL_CACHE_VERSION}"
}

variable "VEGITO_EXAMPLE_APPLICATION_TESTS_IMAGE_DOCKER_BUILDX_CACHE_WRITE_LATEST" {
  description = "local write cache (latest)"
  default     = "type=local,mode=max,dest=${VEGITO_EXAMPLE_APPLICATION_TESTS_IMAGE_DOCKER_BUILDX_LOCAL_CACHE_LATEST}"
}

variable "VEGITO_EXAMPLE_APPLICATION_TESTS_IMAGE_DOCKER_BUILDX_LOCAL_CACHE_READ_VERSION" {
  description = "local read cache (version)"
  default     = "type=local,src=${VEGITO_EXAMPLE_APPLICATION_TESTS_IMAGE_DOCKER_BUILDX_LOCAL_CACHE_VERSION}"
}

variable "VEGITO_EXAMPLE_APPLICATION_TESTS_IMAGE_DOCKER_BUILDX_LOCAL_CACHE_READ_LATEST" {
  description = "local read cache (latest)"
  default     = "type=local,src=${VEGITO_EXAMPLE_APPLICATION_TESTS_IMAGE_DOCKER_BUILDX_LOCAL_CACHE_LATEST}"
}

group "vegito-example-application-tests-ci" {
  targets = [
    "vegito-example-application-tests-version-ci",
    "vegito-example-application-tests-latest-ci",
  ]

}

variable "VEGITO_EXAMPLE_APPLICATION_TESTS_ROBOTFRAMEWORK_CONTEXT_CI" {
  default = "docker-image://${LOCAL_ROBOTFRAMEWORK_IMAGE_VERSION}"
}

target "vegito-example-application-tests-version-ci" {
  contexts = {
    robotframework = VEGITO_EXAMPLE_APPLICATION_TESTS_ROBOTFRAMEWORK_CONTEXT_CI
  }
  context    = VEGITO_EXAMPLE_APPLICATION_TESTS_DIR
  dockerfile = "Dockerfile"
  tags = [
    VEGITO_EXAMPLE_APPLICATION_TESTS_IMAGE,
  ]
  cache-from = concat(
    USE_REGISTRY_CACHE ? [
      "type=registry,ref=${VEGITO_EXAMPLE_APPLICATION_TESTS_IMAGE_REGISTRY_CACHE}"
    ] : [],
    ENABLE_LOCAL_CACHE ? [
      VEGITO_EXAMPLE_APPLICATION_TESTS_IMAGE_DOCKER_BUILDX_LOCAL_CACHE_READ_VERSION
    ] : [],
    [
      "type=inline,ref=${VEGITO_EXAMPLE_APPLICATION_TESTS_IMAGE_LATEST}"
    ]
  )
  cache-to = concat(
    ENABLE_LOCAL_CACHE ? [
      VEGITO_EXAMPLE_APPLICATION_TESTS_IMAGE_DOCKER_BUILDX_CACHE_WRITE_VERSION
    ] : []
  )
  platforms = platforms
}

target "vegito-example-application-tests" {
  context    = VEGITO_EXAMPLE_APPLICATION_TESTS_DIR
  dockerfile = "Dockerfile"
  contexts = {
    robotframework = "docker-image://${LOCAL_ROBOTFRAMEWORK_IMAGE_VERSION}"
  }
  tags = [
    VEGITO_EXAMPLE_APPLICATION_TESTS_IMAGE,
    VEGITO_EXAMPLE_APPLICATION_TESTS_IMAGE_LATEST,
  ]
  cache-from = concat(
    USE_REGISTRY_CACHE ? [
      "type=registry,ref=${VEGITO_EXAMPLE_APPLICATION_TESTS_IMAGE_REGISTRY_CACHE}"
    ] : [],
    ENABLE_LOCAL_CACHE ? [
      VEGITO_EXAMPLE_APPLICATION_TESTS_IMAGE_DOCKER_BUILDX_LOCAL_CACHE_READ_LATEST
    ] : [],
    [
      "type=inline,ref=${VEGITO_EXAMPLE_APPLICATION_TESTS_IMAGE_LATEST}"
    ]
  )
  cache-to = concat(
    ENABLE_LOCAL_CACHE ? [
      VEGITO_EXAMPLE_APPLICATION_TESTS_IMAGE_DOCKER_BUILDX_CACHE_WRITE_LATEST
    ] : [],
    [
      "type=inline"
    ]
  )
}

target "vegito-example-application-tests-latest-ci" {
  contexts = {
    robotframework = VEGITO_EXAMPLE_APPLICATION_TESTS_ROBOTFRAMEWORK_CONTEXT_CI
  }
  context    = VEGITO_EXAMPLE_APPLICATION_TESTS_DIR
  dockerfile = "Dockerfile"
  tags = [
    VEGITO_EXAMPLE_APPLICATION_TESTS_IMAGE_LATEST,
  ]
  cache-from = concat(
    USE_REGISTRY_CACHE ? [
      "type=registry,ref=${VEGITO_EXAMPLE_APPLICATION_TESTS_IMAGE_REGISTRY_CACHE}"
    ] : [],
    ENABLE_LOCAL_CACHE ? [
      VEGITO_EXAMPLE_APPLICATION_TESTS_IMAGE_DOCKER_BUILDX_LOCAL_CACHE_READ_LATEST
    ] : [],
    [
      "type=inline,ref=${VEGITO_EXAMPLE_APPLICATION_TESTS_IMAGE_LATEST}"
    ]
  )
  cache-to = concat(
    USE_REGISTRY_CACHE ? [
      "type=registry,ref=${VEGITO_EXAMPLE_APPLICATION_TESTS_IMAGE_REGISTRY_CACHE},mode=max"
    ] : [],
    ENABLE_LOCAL_CACHE ? [
      VEGITO_EXAMPLE_APPLICATION_TESTS_IMAGE_DOCKER_BUILDX_CACHE_WRITE_LATEST
    ] : []
  )
  platforms = platforms
}
