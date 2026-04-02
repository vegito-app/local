variable "VEGITO_EXAMPLE_APPLICATION_TESTS_DIR" {
  default = "${VEGITO_EXAMPLE_APPLICATION_DIR}/tests"
}

variable "VEGITO_EXAMPLE_APPLICATION_TESTS_ROBOTFRAMEWORK_CONTEXT" {
  default = "docker-image://${VEGITO_EXAMPLE_APPLICATION_CACHE_IMAGES_BASE}/tests"
}

variable "VEGITO_EXAMPLE_APPLICATION_TESTS_IMAGES_BASE" {
  default = "${VEGITO_EXAMPLE_APPLICATION_PUBLIC_IMAGES_BASE}:tests"
}

variable "VEGITO_EXAMPLE_APPLICATION_TESTS_IMAGE" {
  # default = notequal("latest", VERSION) ? "${VEGITO_LOCAL_PUBLIC_IMAGES_BASE}:tests-${VERSION}" : ""
  default = "${VEGITO_EXAMPLE_APPLICATION_TESTS_IMAGES_BASE}-${VERSION}"
}

variable "VEGITO_EXAMPLE_APPLICATION_TESTS_IMAGE_LATEST" {
  default = "${VEGITO_EXAMPLE_APPLICATION_TESTS_IMAGES_BASE}-latest"
}

variable "VEGITO_EXAMPLE_APPLICATION_TESTS_IMAGE_REGISTRY_CACHE" {
  default = "${VEGITO_EXAMPLE_APPLICATION_CACHE_IMAGES_BASE}/tests"
}

variable "VEGITO_EXAMPLE_APPLICATION_TESTS_IMAGE_DOCKER_BUILDX_LOCAL_CACHE" {
  default = "${VEGITO_EXAMPLE_APPLICATION_DIR}/tests/.containers/buildx-cache"
}

variable "VEGITO_EXAMPLE_APPLICATION_TESTS_IMAGE_DOCKER_BUILDX_CACHE_WRITE" {
  description = "local write cache for clarinet image build"
  default     = "type=local,mode=max,dest=${VEGITO_EXAMPLE_APPLICATION_TESTS_IMAGE_DOCKER_BUILDX_LOCAL_CACHE}"
}

variable "VEGITO_EXAMPLE_APPLICATION_TESTS_IMAGE_DOCKER_BUILDX_LOCAL_CACHE_READ" {
  description = "local read cache for clarinet image build (cannot be used before first write)"
  default     = "type=local,src=${VEGITO_EXAMPLE_APPLICATION_TESTS_IMAGE_DOCKER_BUILDX_LOCAL_CACHE}"
}

group "vegito-example-application-tests-ci" {
  targets = [
    "vegito-example-application-tests-version-ci",
    "vegito-example-application-tests-latest-ci",
  ]
}

target "vegito-example-application-tests-version-ci" {
  contexts = {
    robotframework = VEGITO_EXAMPLE_APPLICATION_TESTS_ROBOTFRAMEWORK_CONTEXT
  }
  context    = VEGITO_EXAMPLE_APPLICATION_TESTS_DIR
  dockerfile = "Dockerfile"
  tags = [
    VEGITO_EXAMPLE_APPLICATION_TESTS_IMAGE,
  ]
  cache-from = [
    USE_REGISTRY_CACHE ? "type=registry,ref=${VEGITO_EXAMPLE_APPLICATION_TESTS_IMAGE_REGISTRY_CACHE}" : "",
    "type=inline,ref=${VEGITO_EXAMPLE_APPLICATION_TESTS_IMAGE_LATEST}",
  ]
  cache-to  = []
  platforms = platforms
}

target "vegito-example-application-tests" {
  context    = VEGITO_EXAMPLE_APPLICATION_TESTS_DIR
  dockerfile = "Dockerfile"
  contexts = {
    robotframework = VEGITO_EXAMPLE_APPLICATION_TESTS_ROBOTFRAMEWORK_CONTEXT
  }
  tags = [
    VEGITO_EXAMPLE_APPLICATION_TESTS_IMAGE,
    VEGITO_EXAMPLE_APPLICATION_TESTS_IMAGE_LATEST,
  ]
  cache-from = [
    USE_REGISTRY_CACHE ? "type=registry,ref=${VEGITO_EXAMPLE_APPLICATION_TESTS_IMAGE_REGISTRY_CACHE}" : "",
    VEGITO_EXAMPLE_APPLICATION_TESTS_IMAGE_DOCKER_BUILDX_LOCAL_CACHE_READ,
    "type=inline,ref=${VEGITO_EXAMPLE_APPLICATION_TESTS_IMAGE_LATEST}",
  ]
  cache-to = [
    USE_REGISTRY_CACHE ? "type=registry,ref=${VEGITO_EXAMPLE_APPLICATION_TESTS_IMAGE_REGISTRY_CACHE}" : VEGITO_EXAMPLE_APPLICATION_TESTS_IMAGE_DOCKER_BUILDX_CACHE_WRITE,
  ]
}

target "vegito-example-application-tests-latest-ci" {
  contexts = {
    robotframework = VEGITO_EXAMPLE_APPLICATION_TESTS_ROBOTFRAMEWORK_CONTEXT
  }
  context    = VEGITO_EXAMPLE_APPLICATION_TESTS_DIR
  dockerfile = "Dockerfile"
  tags = [
    VEGITO_EXAMPLE_APPLICATION_TESTS_IMAGE_LATEST,
  ]
  cache-from = [
    USE_REGISTRY_CACHE ? "type=registry,ref=${VEGITO_EXAMPLE_APPLICATION_TESTS_IMAGE_REGISTRY_CACHE}" : "",
    "type=inline,ref=${VEGITO_EXAMPLE_APPLICATION_TESTS_IMAGE_LATEST}",
  ]
  cache-to = [
    USE_REGISTRY_CACHE ? "type=registry,ref=${VEGITO_EXAMPLE_APPLICATION_TESTS_IMAGE_REGISTRY_CACHE},mode=max" : "type=inline"
  ]
  platforms = platforms
}
