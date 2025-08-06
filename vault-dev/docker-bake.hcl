variable "VAULT_DEV_IMAGE_VERSION" {
  default = notequal("latest", LOCAL_VERSION) ? "${PUBLIC_IMAGES_BASE}:vault-dev-${LOCAL_VERSION}" : ""
}

variable "LATEST_VAULT_DEV_IMAGE" {
  default = "${PUBLIC_IMAGES_BASE}:vault-dev-latest"
}

target "vault-dev-ci" {
  context    = "${LOCAL_DIR}/vault-dev"
  dockerfile = "Dockerfile"
  tags = [
    LATEST_VAULT_DEV_IMAGE,
    notequal("", LOCAL_VERSION) ? VAULT_DEV_IMAGE_VERSION : "",
  ]
  cache-from = [
    LATEST_VAULT_DEV_IMAGE
  ]
  cache-to  = ["type=inline"]
  platforms = platforms
}

variable "LOCAL_VAULT_DEV_IMAGE_DOCKER_BUILDX_LOCAL_CACHE_WRITE" {
  description = "local write cache for builder image build"
}

variable "LOCAL_VAULT_DEV_IMAGE_DOCKER_BUILDX_LOCAL_CACHE_READ" {
  description = "local read cache for builder image build (cannot be used before first write)"
}

target "vault-dev" {
  context    = "${LOCAL_DIR}/vault-dev"
  dockerfile = "Dockerfile"
  tags = [
    LATEST_VAULT_DEV_IMAGE,
    notequal("", LOCAL_VERSION) ? VAULT_DEV_IMAGE_VERSION : "",
  ]
  cache-from = [
    LATEST_VAULT_DEV_IMAGE,
    LOCAL_VAULT_DEV_IMAGE_DOCKER_BUILDX_LOCAL_CACHE_READ,
  ]
  cache-to = [
    LOCAL_VAULT_DEV_IMAGE_DOCKER_BUILDX_LOCAL_CACHE_WRITE
  ]
}
