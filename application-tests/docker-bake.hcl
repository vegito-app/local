variable "LOCAL_APPLICATION_TESTS_IMAGES_BASE" {
  default = "${PUBLIC_IMAGES_BASE}:application-tests"
}

variable "LOCAL_APPLICATION_TESTS_IMAGE_VERSION" {
  default = notequal("latest", LOCAL_VERSION) ? "${PUBLIC_IMAGES_BASE}:application-tests-${LOCAL_VERSION}" : ""
}

variable "LOCAL_APPLICATION_TESTS_LATEST_IMAGE" {
  default = "${LOCAL_APPLICATION_TESTS_IMAGES_BASE}-latest"
}

target "application-tests-ci" {
  args = {
    builder_image = LOCAL_BUILDER_IMAGE
  }
  context    = "${LOCAL_DIR}/application-tests"
  dockerfile = "Dockerfile"
  tags = [
    LOCAL_APPLICATION_TESTS_IMAGE_VERSION,
    LOCAL_APPLICATION_TESTS_LATEST_IMAGE,
  ]
  cache-from = [
    LOCAL_APPLICATION_TESTS_LATEST_IMAGE,
    LOCAL_APPLICATION_TESTS_IMAGE_DOCKER_BUILDX_LOCAL_CACHE_READ
  ]
  cache-to = [
    "type=inline",
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
    builder_image = LOCAL_BUILDER_IMAGE
  }
  tags = [
    LOCAL_APPLICATION_TESTS_IMAGE_VERSION,
    LOCAL_APPLICATION_TESTS_LATEST_IMAGE,
  ]
  cache-from = [
    LOCAL_APPLICATION_TESTS_IMAGE_DOCKER_BUILDX_LOCAL_CACHE_READ,
  ]
  cache-to = [
    LOCAL_APPLICATION_TESTS_IMAGE_DOCKER_BUILDX_LOCAL_CACHE_WRITE,
  ]
}
