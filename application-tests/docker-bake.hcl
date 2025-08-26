variable "LOCAL_APPLICATION_TESTS_IMAGES_BASE" {
  default = "${VEGITO_LOCAL_PUBLIC_IMAGES_BASE}:application-tests"
}

variable "LOCAL_APPLICATION_TESTS_IMAGE_VERSION" {
  default = notequal("latest", VERSION) ? "${VEGITO_LOCAL_PUBLIC_IMAGES_BASE}:application-tests-${VERSION}" : ""
}

variable "LOCAL_APPLICATION_TESTS_IMAGE_LATEST" {
  default = "${LOCAL_APPLICATION_TESTS_IMAGES_BASE}-latest"
}

variable "LOCAL_APPLICATION_TESTS_REGISTRY_CACHE_IMAGE" {
  default = "${VEGITO_LOCAL_PUBLIC_IMAGES_BASE}/cache/application-tests"
}

target "application-tests-ci" {
  args = {
    builder_image = LOCAL_BUILDER_IMAGE_LATEST
  }
  context    = "${LOCAL_DIR}/application-tests"
  dockerfile = "Dockerfile"
  tags = [
    LOCAL_APPLICATION_TESTS_IMAGE_VERSION,
    LOCAL_APPLICATION_TESTS_IMAGE_LATEST,
  ]
  cache-from = [
    USE_REGISTRY_CACHE ? "type=registry,ref=${LOCAL_APPLICATION_TESTS_REGISTRY_CACHE_IMAGE}" : "",
    "type=inline,ref=${LOCAL_APPLICATION_TESTS_IMAGE_LATEST}",
    LOCAL_APPLICATION_TESTS_IMAGE_DOCKER_BUILDX_LOCAL_CACHE_READ,
  ]
  cache-to = [
    USE_REGISTRY_CACHE ? "type=registry,ref=${LOCAL_APPLICATION_TESTS_REGISTRY_CACHE_IMAGE},mode=max" : "type=inline"
  ]
}

variable "LOCAL_APPLICATION_TESTS_IMAGE_DOCKER_BUILDX_LOCAL_CACHE_WRITE" {
  description = "local write cache for tests image build"
}

variable "LOCAL_APPLICATION_TESTS_IMAGE_DOCKER_BUILDX_LOCAL_CACHE_READ" {
  description = "local read cache for tests image build (cannot be used before first write)"
}

target "application-tests" {
  context    = "${LOCAL_DIR}/application-tests"
  dockerfile = "Dockerfile"
  args = {
    builder_image = LOCAL_BUILDER_IMAGE_LATEST
  }
  tags = [
    LOCAL_APPLICATION_TESTS_IMAGE_VERSION,
    LOCAL_APPLICATION_TESTS_IMAGE_LATEST,
  ]
  cache-from = [
    USE_REGISTRY_CACHE ? "type=registry,ref=${LOCAL_APPLICATION_TESTS_REGISTRY_CACHE_IMAGE}" : "",
    LOCAL_APPLICATION_TESTS_IMAGE_DOCKER_BUILDX_LOCAL_CACHE_READ,
    "type=inline,ref=${LOCAL_APPLICATION_TESTS_IMAGE_LATEST}",
  ]
  cache-to = [
    USE_REGISTRY_CACHE ? "type=registry,ref=${LOCAL_APPLICATION_TESTS_REGISTRY_CACHE_IMAGE}" : LOCAL_APPLICATION_TESTS_IMAGE_DOCKER_BUILDX_LOCAL_CACHE_WRITE,
  ]
}
