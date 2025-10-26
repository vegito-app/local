variable "EXAMPLE_APPLICATION_TESTS_DIR" {
  default = "${EXAMPLE_APPLICATION_DIR}/tests"
}

variable "EXAMPLE_APPLICATION_TESTS_IMAGES_BASE" {
  default = "${VEGITO_LOCAL_PUBLIC_IMAGES_BASE}:example-application-tests"
}

variable "EXAMPLE_APPLICATION_TESTS_IMAGE_VERSION" {
  default = notequal("latest", VERSION) ? "${VEGITO_LOCAL_PUBLIC_IMAGES_BASE}:example-application-tests-${VERSION}" : ""
}

variable "EXAMPLE_APPLICATION_TESTS_IMAGE_LATEST" {
  default = "${EXAMPLE_APPLICATION_TESTS_IMAGES_BASE}-latest"
}

variable "EXAMPLE_APPLICATION_TESTS_IMAGE_REGISTRY_CACHE" {
  default = "${VEGITO_LOCAL_PUBLIC_IMAGES_BASE}/cache/example-application-tests"
}

variable "EXAMPLE_APPLICATION_TESTS_IMAGE_REGISTRY_CACHE_CI" {
  default = "${VEGITO_LOCAL_PUBLIC_IMAGES_BASE}/cache/example-application-tests/ci"
}

target "example-application-tests-ci" {
  args = {
    robotframework_image = LOCAL_ROBOTFRAMEWORK_TESTS_IMAGE_VERSION
  }
  context    = EXAMPLE_APPLICATION_TESTS_DIR
  dockerfile = "Dockerfile"
  tags = [
    EXAMPLE_APPLICATION_TESTS_IMAGE_VERSION,
    EXAMPLE_APPLICATION_TESTS_IMAGE_LATEST,
  ]
  cache-from = [
    USE_REGISTRY_CACHE ? "type=registry,ref=${EXAMPLE_APPLICATION_TESTS_IMAGE_REGISTRY_CACHE_CI}" : "",
    "type=inline,ref=${EXAMPLE_APPLICATION_TESTS_IMAGE_LATEST}",
    EXAMPLE_APPLICATION_TESTS_IMAGE_DOCKER_BUILDX_LOCAL_CACHE_READ,
  ]
  cache-to = [
    USE_REGISTRY_CACHE ? "type=registry,ref=${EXAMPLE_APPLICATION_TESTS_IMAGE_REGISTRY_CACHE_CI},mode=max" : "type=inline"
  ]
  platforms = platforms
}

variable "EXAMPLE_APPLICATION_TESTS_IMAGE_DOCKER_BUILDX_LOCAL_CACHE_WRITE" {
  description = "local write cache for tests image build"
}

variable "EXAMPLE_APPLICATION_TESTS_IMAGE_DOCKER_BUILDX_LOCAL_CACHE_READ" {
  description = "local read cache for tests image build (cannot be used before first write)"
}

target "example-application-tests" {
  context    = EXAMPLE_APPLICATION_TESTS_DIR
  dockerfile = "Dockerfile"
  args = {
    robotframework_image = LOCAL_ROBOTFRAMEWORK_TESTS_IMAGE_VERSION
  }
  tags = [
    EXAMPLE_APPLICATION_TESTS_IMAGE_VERSION,
    EXAMPLE_APPLICATION_TESTS_IMAGE_LATEST,
  ]
  cache-from = [
    USE_REGISTRY_CACHE ? "type=registry,ref=${EXAMPLE_APPLICATION_TESTS_IMAGE_REGISTRY_CACHE}" : "",
    EXAMPLE_APPLICATION_TESTS_IMAGE_DOCKER_BUILDX_LOCAL_CACHE_READ,
    "type=inline,ref=${EXAMPLE_APPLICATION_TESTS_IMAGE_LATEST}",
  ]
  cache-to = [
    USE_REGISTRY_CACHE ? "type=registry,ref=${EXAMPLE_APPLICATION_TESTS_IMAGE_REGISTRY_CACHE}" : EXAMPLE_APPLICATION_TESTS_IMAGE_DOCKER_BUILDX_LOCAL_CACHE_WRITE,
  ]
}
