variable "LOCAL_GITHUB_ACTIONS_RUNNER_IMAGE_VERSION" {
  default = notequal("latest", VERSION) ? "${VEGITO_LOCAL_PUBLIC_IMAGES_BASE}:github-actions-runner-${VERSION}" : ""
}

variable "LOCAL_GITHUB_ACTIONS_RUNNER_IMAGE_LATEST" {
  default = "${VEGITO_LOCAL_PUBLIC_IMAGES_BASE}:github-actions-runner-latest"
}

variable "LOCAL_GITHUB_ACTIONS_RUNNER_IMAGE_DOCKER_BUILDX_CACHE_IMAGE" {
  default = "${VEGITO_LOCAL_PUBLIC_IMAGES_BASE}/cache/github-actions-runner"
}

variable "LOCAL_GITHUB_ACTIONS_RUNNER_IMAGE_DOCKER_BUILDX_CACHE_IMAGE" {
  default = "${VEGITO_LOCAL_PUBLIC_IMAGES_BASE}/cache/github-actions-runner"
}

variable "LOCAL_GITHUB_ACTIONS_RUNNER_IMAGE_DOCKER_BUILDX_CACHE_IMAGE_CI" {
  default = "${VEGITO_LOCAL_PUBLIC_IMAGES_BASE}/cache/github-actions-runner/ci"
}

variable "GITHUB_ACTION_RUNNER_VERSION" {
  description = "current Github Actions Runner version"
  default     = "2.328.0"
}

group "service" {
  targets = ["github-actions-runner"]
}

group "local-service" {
  targets = ["github-actions-runner-local"]
}

target "github-actions-runner-ci" {
  args = {
    docker_buildx_version  = DOCKER_BUILDX_VERSION
    docker_compose_version = DOCKER_COMPOSE_VERSION
    docker_version         = DOCKER_VERSION
    github_runner_version  = GITHUB_ACTION_RUNNER_VERSION
    gitleaks_version       = GITLEAKS_VERSION
    kubectl_version        = KUBECTL_VERSION
    node_version           = NODE_VERSION
    nvm_version            = NVM_VERSION
    terraform_version      = TERRAFORM_VERSION
  }
  context    = "${LOCAL_DIR}/github-actions"
  tags = [
    LOCAL_GITHUB_ACTIONS_RUNNER_IMAGE_LATEST,
    LOCAL_GITHUB_ACTIONS_RUNNER_IMAGE_VERSION,
  ]
  cache-from = [
    USE_REGISTRY_CACHE ? "type=registry,ref=${LOCAL_GITHUB_ACTIONS_RUNNER_IMAGE_DOCKER_BUILDX_CACHE_IMAGE_CI}" : "",
    "type=inline,ref=${LOCAL_GITHUB_ACTIONS_RUNNER_IMAGE_LATEST}",
    LOCAL_GITHUB_ACTIONS_RUNNER_IMAGE_DOCKER_BUILDX_LOCAL_CACHE_READ,
  ]
  cache-to = [
    USE_REGISTRY_CACHE ? "type=registry,ref=${LOCAL_GITHUB_ACTIONS_RUNNER_IMAGE_DOCKER_BUILDX_CACHE_IMAGE_CI},mode=max" : "type=inline"
  ]
  platforms = platforms
}

variable "LOCAL_GITHUB_ACTIONS_RUNNER_IMAGE_DOCKER_BUILDX_CACHE_WRITE" {
  description = "local write cache for github-actions-runner image build"
}

variable "LOCAL_GITHUB_ACTIONS_RUNNER_IMAGE_DOCKER_BUILDX_LOCAL_CACHE_READ" {
  description = "local read cache for github-actions-runner image build (cannot be used before first write)"
}

target "github-actions-runner" {
  args = {
    docker_buildx_version  = DOCKER_BUILDX_VERSION
    docker_compose_version = DOCKER_COMPOSE_VERSION
    docker_version         = DOCKER_VERSION
    github_runner_version  = GITHUB_ACTION_RUNNER_VERSION
    gitleaks_version       = GITLEAKS_VERSION
    kubectl_version        = KUBECTL_VERSION
    node_version           = NODE_VERSION
    nvm_version            = NVM_VERSION
    terraform_version      = TERRAFORM_VERSION
  }
  context    = "${LOCAL_DIR}/github-actions"
  tags = [
    LOCAL_GITHUB_ACTIONS_RUNNER_IMAGE_LATEST,
    LOCAL_GITHUB_ACTIONS_RUNNER_IMAGE_VERSION,
  ]
  cache-from = [
    USE_REGISTRY_CACHE ? "type=registry,ref=${LOCAL_GITHUB_ACTIONS_RUNNER_IMAGE_DOCKER_BUILDX_CACHE_IMAGE}" : "",
    LOCAL_GITHUB_ACTIONS_RUNNER_IMAGE_DOCKER_BUILDX_LOCAL_CACHE_READ,
    "type=inline,ref=${LOCAL_GITHUB_ACTIONS_RUNNER_IMAGE_LATEST}",
  ]
  cache-to = [
    USE_REGISTRY_CACHE ? "type=registry,ref=${LOCAL_GITHUB_ACTIONS_RUNNER_IMAGE_DOCKER_BUILDX_CACHE_IMAGE},mode=max" : LOCAL_GITHUB_ACTIONS_RUNNER_IMAGE_DOCKER_BUILDX_CACHE_WRITE
  ]
}
