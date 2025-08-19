variable "LOCAL_VAULT_DEV_IMAGE_VERSION" {
  default = notequal("latest", VERSION) ? "${VEGITO_LOCAL_PUBLIC_IMAGES_BASE}:vault-dev-${VERSION}" : ""
}

variable "LOCAL_VAULT_DEV_IMAGE_LATEST" {
  default = "${VEGITO_LOCAL_PUBLIC_IMAGES_BASE}:vault-dev-latest"
}

variable "LOCAL_VAULT_DEV_REGISTRY_CACHE_IMAGE" {
  default = "${VEGITO_LOCAL_PUBLIC_IMAGES_BASE}/cache/vault-dev"
}

target "vault-dev-ci" {
  context    = "${LOCAL_DIR}/vault-dev"
  dockerfile = "Dockerfile"
  tags = [
    LOCAL_VAULT_DEV_IMAGE_LATEST,
    LOCAL_VAULT_DEV_IMAGE_VERSION,
  ]
  cache-from = [
    USE_REGISTRY_CACHE ? "type=registry,ref=${LOCAL_VAULT_DEV_REGISTRY_CACHE_IMAGE}" : "",
    LOCAL_VAULT_DEV_IMAGE_LATEST,
    LOCAL_VAULT_DEV_IMAGE_DOCKER_BUILDX_LOCAL_CACHE_READ,
  ]
  cache-to = [
    USE_REGISTRY_CACHE ? "type=registry,ref=${LOCAL_VAULT_DEV_REGISTRY_CACHE_IMAGE},mode=max" : "type=inline"
  ]
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
    LOCAL_VAULT_DEV_IMAGE_LATEST,
    LOCAL_VAULT_DEV_IMAGE_VERSION,
  ]
  cache-from = [
    LOCAL_VAULT_DEV_IMAGE_LATEST,
    LOCAL_VAULT_DEV_IMAGE_DOCKER_BUILDX_LOCAL_CACHE_READ,
    USE_REGISTRY_CACHE ? "type=registry,ref=${LOCAL_VAULT_DEV_REGISTRY_CACHE_IMAGE}" : "",
  ]
  cache-to = [
    USE_REGISTRY_CACHE ? "type=registry,ref=${LOCAL_VAULT_DEV_REGISTRY_CACHE_IMAGE},mode=max" : LOCAL_VAULT_DEV_IMAGE_DOCKER_BUILDX_LOCAL_CACHE_WRITE,
  ]
}
