variable "GITHUB_RUNNER_IMAGE_VERSION" {
  default = notequal("dev", VERSION) ? "${PUBLIC_IMAGES_BASE}:github-runner-${VERSION}" : ""
}

variable "GITHUB_RUNNER_IMAGE_TAG" {
  default = notequal("", VERSION) ? "${PUBLIC_IMAGES_BASE}:github-runner-${VERSION}" : ""
}

variable "LATEST_GITHUB_RUNNER_IMAGE" {
  default = "${PUBLIC_IMAGES_BASE}:github-runner-latest"
}

group "service" {
  targets = ["github-runner"]
}

group "local-service" {
  targets = ["github-runner-local"]
}

target "github-runner-ci" {
  args = {
    builder_image = LATEST_BUILDER_IMAGE
  }
  depends_on = [builder]
  context    = "infra/github"
  tags = [
    LATEST_GITHUB_RUNNER_IMAGE,
    GITHUB_RUNNER_IMAGE_VERSION,
    GITHUB_RUNNER_IMAGE_TAG,
  ]
  cache-from = [
    LATEST_BUILDER_IMAGE,
    LATEST_GITHUB_RUNNER_IMAGE
  ]
  cache-to  = ["type=inline"]
  platforms = platforms
}

variable "GITHUB_ACTIONS_RUNNER_IMAGE_DOCKER_BUILDX_LOCAL_CACHE_WRITE" {
  description = "local write cache for github-actions-runner image build"
}

variable "GITHUB_ACTIONS_RUNNER_IMAGE_DOCKER_BUILDX_LOCAL_CACHE_READ" {
  description = "local read cache for github-actions-runner image build (cannot be used before first write)"
}

target "github-runner" {
  args = {
    builder_image = LATEST_BUILDER_IMAGE
  }
  depends_on = [builder-local]
  context    = "infra/github"
  tags = [
    LATEST_GITHUB_RUNNER_IMAGE,
    GITHUB_RUNNER_IMAGE_VERSION,
    GITHUB_RUNNER_IMAGE_TAG,
  ]
  cache-from = [
    GITHUB_ACTIONS_RUNNER_IMAGE_DOCKER_BUILDX_LOCAL_CACHE_READ,
    BUILDER_IMAGE_DOCKER_BUILDX_LOCAL_CACHE_READ,
  ]
  cache-to = [
    GITHUB_ACTIONS_RUNNER_IMAGE_DOCKER_BUILDX_LOCAL_CACHE_WRITE,
  ]
}
