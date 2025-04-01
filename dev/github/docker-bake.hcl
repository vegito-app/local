variable "GITHUB_RUNNER_IMAGE_VERSION" {
  default = notequal("dev", VERSION) ? "${PUBLIC_IMAGES_BASE}:github-action-runner-${VERSION}" : ""
}

variable "LATEST_GITHUB_RUNNER_IMAGE" {
  default = "${PUBLIC_IMAGES_BASE}:github-action-runner-latest"
}

group "service" {
  targets = ["github-action-runner"]
}

group "local-service" {
  targets = ["github-action-runner-local"]
}

target "github-action-runner-ci" {
  args = {
    docker_version = DOCKER_VERSION
  }
  depends_on = [builder]
  context    = "dev/github"
  tags = [
    LATEST_GITHUB_RUNNER_IMAGE,
    notequal("", VERSION) ? GITHUB_RUNNER_IMAGE_VERSION : "",
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

target "github-action-runner" {
  args = {
    docker_version = DOCKER_VERSION
  }
  depends_on = [builder-local]
  context    = "dev/github"
  tags = [
    LATEST_GITHUB_RUNNER_IMAGE,
    notequal("", VERSION) ? GITHUB_RUNNER_IMAGE_VERSION : "",
  ]
  cache-from = [
    GITHUB_ACTIONS_RUNNER_IMAGE_DOCKER_BUILDX_LOCAL_CACHE_READ,
    BUILDER_IMAGE_DOCKER_BUILDX_LOCAL_CACHE_READ,
  ]
  cache-to = [
    GITHUB_ACTIONS_RUNNER_IMAGE_DOCKER_BUILDX_LOCAL_CACHE_WRITE,
  ]
}
