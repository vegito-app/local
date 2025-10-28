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
  default = "${VEGITO_LOCAL_PUBLIC_IMAGES_BASE}/cache/robotframework"
}

variable "LOCAL_ROBOTFRAMEWORK_TESTS_IMAGE_REGISTRY_CACHE_CI" {
  default = "${VEGITO_LOCAL_PUBLIC_IMAGES_BASE}/cache/robotframework/ci"
}

target "robotframework-ci" {
  args = {
    builder_image = LOCAL_BUILDER_IMAGE_VERSION
  }
  context    = "${LOCAL_DIR}/robotframework"
  dockerfile = "Dockerfile"
  tags = [
    LOCAL_ROBOTFRAMEWORK_IMAGE_VERSION,
    LOCAL_ROBOTFRAMEWORK_TESTS_IMAGE_LATEST,
  ]
  cache-from = [
    USE_REGISTRY_CACHE ? "type=registry,ref=${LOCAL_ROBOTFRAMEWORK_TESTS_IMAGE_REGISTRY_CACHE_CI}" : "",
    "type=inline,ref=${LOCAL_ROBOTFRAMEWORK_TESTS_IMAGE_LATEST}",
    LOCAL_ROBOTFRAMEWORK_TESTS_IMAGE_DOCKER_BUILDX_LOCAL_CACHE_READ,
  ]
  cache-to = [
    USE_REGISTRY_CACHE ? "type=registry,ref=${LOCAL_ROBOTFRAMEWORK_TESTS_IMAGE_REGISTRY_CACHE_CI},mode=max" : "type=inline"
  ]
  platforms = platforms
}

variable "LOCAL_ROBOTFRAMEWORK_TESTS_IMAGE_DOCKER_BUILDX_LOCAL_CACHE_WRITE" {
  description = "local write cache for tests image build"
}

variable "LOCAL_ROBOTFRAMEWORK_TESTS_IMAGE_DOCKER_BUILDX_LOCAL_CACHE_READ" {
  description = "local read cache for tests image build (cannot be used before first write)"
}

target "robotframework" {
  context    = "${LOCAL_DIR}/robotframework"
  dockerfile = "Dockerfile"
  args = {
    builder_image = LOCAL_BUILDER_IMAGE_LATEST
  }
  tags = [
    LOCAL_ROBOTFRAMEWORK_IMAGE_VERSION,
    LOCAL_ROBOTFRAMEWORK_TESTS_IMAGE_LATEST,
  ]
  cache-from = [
    USE_REGISTRY_CACHE ? "type=registry,ref=${LOCAL_ROBOTFRAMEWORK_TESTS_IMAGE_REGISTRY_CACHE}" : "",
    LOCAL_ROBOTFRAMEWORK_TESTS_IMAGE_DOCKER_BUILDX_LOCAL_CACHE_READ,
    "type=inline,ref=${LOCAL_ROBOTFRAMEWORK_TESTS_IMAGE_LATEST}",
  ]
  cache-to = [
    USE_REGISTRY_CACHE ? "type=registry,ref=${LOCAL_ROBOTFRAMEWORK_TESTS_IMAGE_REGISTRY_CACHE}" : LOCAL_ROBOTFRAMEWORK_TESTS_IMAGE_DOCKER_BUILDX_LOCAL_CACHE_WRITE,
  ]
}
