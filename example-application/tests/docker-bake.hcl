variable "VEGITO_EXAMPLE_APPLICATION_TESTS_DIR" {
  default = "${VEGITO_EXAMPLE_APPLICATION_DIR}/tests"
}

variable "VEGITO_EXAMPLE_APPLICATION_TESTS_IMAGES_BASE" {
  default = "${VEGITO_LOCAL_PUBLIC_IMAGES_BASE}:example-application-tests"
}

variable "VEGITO_EXAMPLE_APPLICATION_TESTS_IMAGE_VERSION" {
  default = notequal("latest", VERSION) ? "${VEGITO_LOCAL_PUBLIC_IMAGES_BASE}:example-application-tests-${VERSION}" : ""
}

variable "VEGITO_EXAMPLE_APPLICATION_TESTS_IMAGE_LATEST" {
  default = "${VEGITO_EXAMPLE_APPLICATION_TESTS_IMAGES_BASE}-latest"
}

variable "VEGITO_EXAMPLE_APPLICATION_TESTS_IMAGE_REGISTRY_CACHE" {
  default = "${VEGITO_LOCAL_PUBLIC_IMAGES_BASE}/cache/example-application-tests"
}

variable "VEGITO_EXAMPLE_APPLICATION_TESTS_IMAGE_REGISTRY_CACHE_CI" {
  default = "${VEGITO_LOCAL_PUBLIC_IMAGES_BASE}/cache/example-application-tests/ci"
}

target "example-application-tests-ci" {
  args = {
    robotframework_image = "${VEGITO_LOCAL_PUBLIC_IMAGES_BASE}:robotframework-${LOCAL_VERSION}"
  }
  context    = VEGITO_EXAMPLE_APPLICATION_TESTS_DIR
  dockerfile = "Dockerfile"
  tags = [
    VEGITO_EXAMPLE_APPLICATION_TESTS_IMAGE_VERSION,
    VEGITO_EXAMPLE_APPLICATION_TESTS_IMAGE_LATEST,
  ]
  cache-from = [
    USE_REGISTRY_CACHE ? "type=registry,ref=${VEGITO_EXAMPLE_APPLICATION_TESTS_IMAGE_REGISTRY_CACHE_CI}" : "",
    "type=inline,ref=${VEGITO_EXAMPLE_APPLICATION_TESTS_IMAGE_LATEST}",
    VEGITO_EXAMPLE_APPLICATION_TESTS_IMAGE_DOCKER_BUILDX_LOCAL_CACHE_READ,
  ]
  cache-to = [
    USE_REGISTRY_CACHE ? "type=registry,ref=${VEGITO_EXAMPLE_APPLICATION_TESTS_IMAGE_REGISTRY_CACHE_CI},mode=max" : "type=inline"
  ]
  platforms = platforms
}

variable "VEGITO_EXAMPLE_APPLICATION_TESTS_IMAGE_DOCKER_BUILDX_LOCAL_CACHE_WRITE" {
  description = "local write cache for tests image build"
}

variable "VEGITO_EXAMPLE_APPLICATION_TESTS_IMAGE_DOCKER_BUILDX_LOCAL_CACHE_READ" {
  description = "local read cache for tests image build (cannot be used before first write)"
}

target "example-application-tests" {
  context    = VEGITO_EXAMPLE_APPLICATION_TESTS_DIR
  dockerfile = "Dockerfile"
  args = {
    robotframework_image = "${VEGITO_LOCAL_PUBLIC_IMAGES_BASE}:robotframework-${LOCAL_VERSION}"
  }
  tags = [
    VEGITO_EXAMPLE_APPLICATION_TESTS_IMAGE_VERSION,
    VEGITO_EXAMPLE_APPLICATION_TESTS_IMAGE_LATEST,
  ]
  cache-from = [
    USE_REGISTRY_CACHE ? "type=registry,ref=${VEGITO_EXAMPLE_APPLICATION_TESTS_IMAGE_REGISTRY_CACHE}" : "",
    VEGITO_EXAMPLE_APPLICATION_TESTS_IMAGE_DOCKER_BUILDX_LOCAL_CACHE_READ,
    "type=inline,ref=${VEGITO_EXAMPLE_APPLICATION_TESTS_IMAGE_LATEST}",
  ]
  cache-to = [
    USE_REGISTRY_CACHE ? "type=registry,ref=${VEGITO_EXAMPLE_APPLICATION_TESTS_IMAGE_REGISTRY_CACHE}" : VEGITO_EXAMPLE_APPLICATION_TESTS_IMAGE_DOCKER_BUILDX_LOCAL_CACHE_WRITE,
  ]
}
