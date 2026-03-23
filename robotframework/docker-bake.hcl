variable "LOCAL_ROBOTFRAMEWORK_TESTS_IMAGES_BASE" {
  default = "${VEGITO_LOCAL_PUBLIC_IMAGES_BASE}:robotframework"
}

variable "LOCAL_ROBOTFRAMEWORK_IMAGE_VERSION" {
  default = notequal("latest", VERSION) ? "${VEGITO_LOCAL_PUBLIC_IMAGES_BASE}:robotframework-${VERSION}" : ""
}

variable "LOCAL_ROBOTFRAMEWORK_TESTS_IMAGE_LATEST" {
  default = "${LOCAL_ROBOTFRAMEWORK_TESTS_IMAGES_BASE}-latest"
}

variable "LOCAL_ROBOTFRAMEWORK_TESTS_IMAGE_REGISTRY_CACHE" {
  default = "${VEGITO_LOCAL_CACHE_IMAGES_BASE}/robotframework"
}

variable "LOCAL_ROBOTFRAMEWORK_IMAGE_DOCKER_BUILDX_LOCAL_CACHE" {
  default = "${LOCAL_DOCKER_BUILDX_LOCAL_CACHE_DIR}/robotframework"
}

variable "LOCAL_ROBOTFRAMEWORK_IMAGE_DOCKER_BUILDX_CACHE_WRITE" {
  description = "local write cache for clarinet image build"
  default     = "type=local,mode=max,dest=${LOCAL_ROBOTFRAMEWORK_IMAGE_DOCKER_BUILDX_LOCAL_CACHE}"
}

variable "LOCAL_ROBOTFRAMEWORK_IMAGE_DOCKER_BUILDX_LOCAL_CACHE_READ" {
  description = "local read cache for clarinet image build (cannot be used before first write)"
  default     = "type=local,src=${LOCAL_ROBOTFRAMEWORK_IMAGE_DOCKER_BUILDX_LOCAL_CACHE}"
}

target "robotframework-ci" {
  contexts = {
    debian_image = "target:local-debian-ci"
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
    [
      "type=inline,ref=${LOCAL_ROBOTFRAMEWORK_TESTS_IMAGE_LATEST}"
    ]
  )
  cache-to  = []
  platforms = platforms
}

target "robotframework-latest-ci" {
  contexts = {
    debian_image = "target:local-debian-latest-ci"
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
    [
      "type=inline,ref=${LOCAL_ROBOTFRAMEWORK_TESTS_IMAGE_LATEST}"
    ]
  )
  cache-to = [
    USE_REGISTRY_CACHE ? "type=registry,ref=${LOCAL_ROBOTFRAMEWORK_TESTS_IMAGE_REGISTRY_CACHE},mode=max" : "type=inline"
  ]
  platforms = platforms
}

target "robotframework" {
  context    = "${LOCAL_DIR}/robotframework"
  dockerfile = "Dockerfile"
  contexts = {
    debian_image = "target:local-debian"
  }
  tags = [
    LOCAL_ROBOTFRAMEWORK_IMAGE_VERSION,
    LOCAL_ROBOTFRAMEWORK_TESTS_IMAGE_LATEST,
  ]
  cache-from = concat(
    ENABLE_LOCAL_CACHE ? [
      LOCAL_ROBOTFRAMEWORK_IMAGE_DOCKER_BUILDX_LOCAL_CACHE_READ
    ] : [],
    USE_REGISTRY_CACHE ? [
      "type=registry,ref=${LOCAL_ROBOTFRAMEWORK_TESTS_IMAGE_REGISTRY_CACHE}"
    ] : [],
    [
      "type=inline,ref=${LOCAL_ROBOTFRAMEWORK_TESTS_IMAGE_LATEST}"
    ]
  )
  cache-to = concat(
    ENABLE_LOCAL_CACHE ? [
      LOCAL_ROBOTFRAMEWORK_IMAGE_DOCKER_BUILDX_CACHE_WRITE
    ] : []
  )
}
