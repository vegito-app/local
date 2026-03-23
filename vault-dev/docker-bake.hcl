variable "LOCAL_VAULT_DEV_IMAGE_VERSION" {
  default = notequal("latest", VERSION) ? "${VEGITO_LOCAL_PUBLIC_IMAGES_BASE}:vault-dev-${VERSION}" : ""
}

variable "LOCAL_VAULT_DEV_IMAGE_LATEST" {
  default = "${VEGITO_LOCAL_PUBLIC_IMAGES_BASE}:vault-dev-latest"
}

variable "LOCAL_VAULT_DEV_IMAGE_REGISTRY_CACHE" {
  default = "${VEGITO_LOCAL_CACHE_IMAGES_BASE}/vault-dev"
}

variable "LOCAL_VAULT_DEV_IMAGE_DOCKER_BUILDX_LOCAL_CACHE" {
  default = "${LOCAL_DOCKER_BUILDX_LOCAL_CACHE_DIR}/vault-dev"
}

variable "LOCAL_VAULT_DEV_IMAGE_DOCKER_BUILDX_LOCAL_CACHE_WRITE" {
  description = "local write cache for builder image build"
  default     = "type=local,mode=max,dest=${LOCAL_VAULT_DEV_IMAGE_DOCKER_BUILDX_LOCAL_CACHE}"
}

variable "LOCAL_VAULT_DEV_IMAGE_DOCKER_BUILDX_LOCAL_CACHE_READ" {
  description = "local read cache for builder image build (cannot be used before first write)"
  default     = "type=local,src=${LOCAL_VAULT_DEV_IMAGE_DOCKER_BUILDX_LOCAL_CACHE}"
}

target "vault-dev-ci" {
  contexts = {
    debian = "target:local-debian-ci"
  }
  context    = "${LOCAL_DIR}/vault-dev"
  dockerfile = "Dockerfile"
  tags = [
    LOCAL_VAULT_DEV_IMAGE_VERSION,
  ]
  cache-from = concat(
    USE_REGISTRY_CACHE ? [
      "type=registry,ref=${LOCAL_VAULT_DEV_IMAGE_REGISTRY_CACHE}"
    ] : [],
    [
      "type=inline,ref=${LOCAL_VAULT_DEV_IMAGE_LATEST}"
    ]
  )
  cache-to  = []
  platforms = platforms
}

target "vault-dev-latest-ci" {
  contexts = {
    debian = "target:local-debian-ci"
  }
  context    = "${LOCAL_DIR}/vault-dev"
  dockerfile = "Dockerfile"
  tags = [
    LOCAL_VAULT_DEV_IMAGE_LATEST,
  ]
  cache-from = concat(
    USE_REGISTRY_CACHE ? [
      "type=registry,ref=${LOCAL_VAULT_DEV_IMAGE_REGISTRY_CACHE}"
    ] : [],
    [
      "type=inline,ref=${LOCAL_VAULT_DEV_IMAGE_LATEST}"
    ]
  )
  cache-to = [
    USE_REGISTRY_CACHE ? "type=registry,ref=${LOCAL_VAULT_DEV_IMAGE_REGISTRY_CACHE},mode=max" : "type=inline"
  ]
  platforms = platforms
}

target "vault-dev" {
  contexts = {
    debian = "target:local-debian"
  }
  context    = "${LOCAL_DIR}/vault-dev"
  dockerfile = "Dockerfile"
  tags = [
    LOCAL_VAULT_DEV_IMAGE_LATEST,
    LOCAL_VAULT_DEV_IMAGE_VERSION,
  ]
  cache-from = concat(
    ENABLE_LOCAL_CACHE ? [
      LOCAL_VAULT_DEV_IMAGE_DOCKER_BUILDX_LOCAL_CACHE_READ
    ] : [],
    USE_REGISTRY_CACHE ? [
      "type=registry,ref=${LOCAL_VAULT_DEV_IMAGE_REGISTRY_CACHE}"
    ] : [],
    [
      "type=inline,ref=${LOCAL_VAULT_DEV_IMAGE_LATEST}"
    ]
  )
  cache-to = concat(
    ENABLE_LOCAL_CACHE ? [
      LOCAL_VAULT_DEV_IMAGE_DOCKER_BUILDX_LOCAL_CACHE_WRITE
    ] : []
  )
}
