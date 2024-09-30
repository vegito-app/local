variable "GITHUB_RUNNER_IMAGE_VERSION" {
  default = notequal("dev", VERSION) ? "${PUBLIC_IMAGES_BASE}:github-runner-${VERSION}" : ""
}

variable "GITHUB_RUNNER_IMAGE_TAG" {
  default = notequal("", GIT_TAG) ? "${PUBLIC_IMAGES_BASE}:github-runner-${GIT_TAG}" : ""
}

variable "LATEST_GITHUB_RUNNER_IMAGE" {
  default = "${PUBLIC_IMAGES_BASE}:github-runner-latest"
}

target "github-runner" {
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
  cache-to = ["type=inline"]
  platforms = [
    "linux/amd64",
    "linux/arm64"
  ]
}

target "local-github-runner" {
  args = {
    builder_image = LATEST_BUILDER_IMAGE
  }
  depends_on = [local-builder]
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
  cache-to = ["type=inline"]
}
