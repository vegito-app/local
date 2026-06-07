variable "LOCAL_GITHUB_ACTIONS_RUNNER_IMAGE_VERSION" {
  default = "${VEGITO_LOCAL_PUBLIC_IMAGES_BASE_NAME}:github-actions-runner-${VERSION}"
}

variable "LOCAL_GITHUB_ACTIONS_RUNNER_IMAGE_LATEST" {
  default = "${VEGITO_LOCAL_PUBLIC_IMAGES_BASE_NAME}:github-actions-runner-latest"
}

variable "LOCAL_GITHUB_ACTIONS_RUNNER_IMAGE_DOCKER_BUILDX_CACHE_IMAGE" {
  default = "${VEGITO_LOCAL_CACHE_IMAGES_BASE}/github-actions-runner"
}

variable "LOCAL_GITHUB_ACTIONS_RUNNER_IMAGE_DOCKER_BUILDX_CACHE_IMAGE_CI" {
  default = "${VEGITO_LOCAL_CACHE_IMAGES_BASE}/github-actions-runner/ci"
}

variable "LOCAL_GITHUB_ACTIONS_RUNNER_IMAGE_DOCKER_BUILDX_LOCAL_CACHE_VERSION" {
  default = "${LOCAL_DOCKER_BUILDX_LOCAL_CACHE_DIR}/github-actions-runner-version"
}

variable "LOCAL_GITHUB_ACTIONS_RUNNER_IMAGE_DOCKER_BUILDX_LOCAL_CACHE_LATEST" {
  default = "${LOCAL_DOCKER_BUILDX_LOCAL_CACHE_DIR}/github-actions-runner-latest"
}

variable "LOCAL_GITHUB_ACTIONS_RUNNER_IMAGE_DOCKER_BUILDX_CACHE_WRITE_VERSION" {
  description = "local write cache for clarinet image build (version)"
  default     = "type=local,mode=max,dest=${LOCAL_GITHUB_ACTIONS_RUNNER_IMAGE_DOCKER_BUILDX_LOCAL_CACHE_VERSION}"
}

variable "LOCAL_GITHUB_ACTIONS_RUNNER_IMAGE_DOCKER_BUILDX_CACHE_WRITE_LATEST" {
  description = "local write cache for clarinet image build (latest)"
  default     = "type=local,mode=max,dest=${LOCAL_GITHUB_ACTIONS_RUNNER_IMAGE_DOCKER_BUILDX_LOCAL_CACHE_LATEST}"
}

variable "LOCAL_GITHUB_ACTIONS_RUNNER_IMAGE_DOCKER_BUILDX_LOCAL_CACHE_READ_VERSION" {
  description = "local read cache for clarinet image build (version) (cannot be used before first write)"
  default     = "type=local,src=${LOCAL_GITHUB_ACTIONS_RUNNER_IMAGE_DOCKER_BUILDX_LOCAL_CACHE_VERSION}"
}

variable "LOCAL_GITHUB_ACTIONS_RUNNER_IMAGE_DOCKER_BUILDX_LOCAL_CACHE_READ_LATEST" {
  description = "local read cache for clarinet image build (latest) (cannot be used before first write)"
  default     = "type=local,src=${LOCAL_GITHUB_ACTIONS_RUNNER_IMAGE_DOCKER_BUILDX_LOCAL_CACHE_LATEST}"
}

variable "GITHUB_ACTION_RUNNER_VERSION" {
  description = "current Github Actions Runner version"
  default     = "2.330.0"
}

group "local-github-actions-runner-ci" {
  targets = [
    "local-github-actions-runner-version-ci",
    "local-github-actions-runner-latest-ci",
  ]
}

target "local-github-actions-runner-base" {
  contexts = {
    debian_project_builder = "docker-image://${VEGITO_DOCKER_TRIXIE_DEBIAN_GOLANG_PROJECT_BUILDER_DOCKER_IMAGE_LATEST}"
  }
  args = {
    github_runner_version = GITHUB_ACTION_RUNNER_VERSION
  }
  context = "${LOCAL_DIR}/github-actions"
}

target "local-github-actions-runner-version-ci" {
  inherits = ["local-github-actions-runner-base"]
  tags = [
    LOCAL_GITHUB_ACTIONS_RUNNER_IMAGE_VERSION,
  ]
  cache-from = concat(
    USE_REGISTRY_CACHE ? [
      "type=registry,ref=${LOCAL_GITHUB_ACTIONS_RUNNER_IMAGE_DOCKER_BUILDX_CACHE_IMAGE_CI}"
    ] : [],
    ENABLE_LOCAL_CACHE ? [
      LOCAL_GITHUB_ACTIONS_RUNNER_IMAGE_DOCKER_BUILDX_LOCAL_CACHE_READ_VERSION
    ] : [],
    [
      LOCAL_GITHUB_ACTIONS_RUNNER_IMAGE_LATEST
    ]
  )
  cache-to = concat(
    ENABLE_LOCAL_CACHE ? [
      LOCAL_GITHUB_ACTIONS_RUNNER_IMAGE_DOCKER_BUILDX_CACHE_WRITE_VERSION
    ] : [],
  )
  platforms = platforms
}

target "local-github-actions-runner-latest-ci" {
  inherits = ["local-github-actions-runner-base"]
  tags = [
    LOCAL_GITHUB_ACTIONS_RUNNER_IMAGE_LATEST,
  ]
  cache-from = concat(
    USE_REGISTRY_CACHE ? [
      "type=registry,ref=${LOCAL_GITHUB_ACTIONS_RUNNER_IMAGE_DOCKER_BUILDX_CACHE_IMAGE_CI}"
    ] : [],
    ENABLE_LOCAL_CACHE ? [
      LOCAL_GITHUB_ACTIONS_RUNNER_IMAGE_DOCKER_BUILDX_LOCAL_CACHE_READ_LATEST
    ] : [],
    [
      LOCAL_GITHUB_ACTIONS_RUNNER_IMAGE_LATEST
    ]
  )
  cache-to = concat(
    USE_REGISTRY_CACHE ? [
      "type=registry,ref=${LOCAL_GITHUB_ACTIONS_RUNNER_IMAGE_DOCKER_BUILDX_CACHE_IMAGE_CI},mode=max"
    ] : [],
    ENABLE_LOCAL_CACHE ? [
      LOCAL_GITHUB_ACTIONS_RUNNER_IMAGE_DOCKER_BUILDX_CACHE_WRITE_LATEST
    ] : [],
    [
      "type=inline"
    ]
  )
  platforms = platforms
}

target "local-github-actions-runner" {
  inherits = ["local-github-actions-runner-base"]
  tags = [
    LOCAL_GITHUB_ACTIONS_RUNNER_IMAGE_LATEST,
    LOCAL_GITHUB_ACTIONS_RUNNER_IMAGE_VERSION,
  ]
  cache-from = concat(
    USE_REGISTRY_CACHE ? [
      "type=registry,ref=${LOCAL_GITHUB_ACTIONS_RUNNER_IMAGE_DOCKER_BUILDX_CACHE_IMAGE}"
    ] : [],
    ENABLE_LOCAL_CACHE ? [
      LOCAL_GITHUB_ACTIONS_RUNNER_IMAGE_DOCKER_BUILDX_LOCAL_CACHE_READ_LATEST
    ] : [],
    [
      LOCAL_GITHUB_ACTIONS_RUNNER_IMAGE_LATEST
    ]
  )
  cache-to = concat(
    ENABLE_LOCAL_CACHE ? [
      LOCAL_GITHUB_ACTIONS_RUNNER_IMAGE_DOCKER_BUILDX_CACHE_WRITE_LATEST
    ] : []
  )
}
