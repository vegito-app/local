variable "LOCAL_VAULT_DEV_IMAGE_VERSION" {
  default = "${VEGITO_LOCAL_PUBLIC_IMAGES_BASE_NAME}:vault-dev-${VERSION}"
}

variable "LOCAL_VAULT_DEV_IMAGE_LATEST" {
  default = "${VEGITO_LOCAL_PUBLIC_IMAGES_BASE_NAME}:vault-dev-latest"
}

variable "LOCAL_VAULT_DEV_IMAGE_REGISTRY_CACHE" {
  default = "${VEGITO_LOCAL_CACHE_IMAGES_BASE}/vault-dev"
}

variable "LOCAL_VAULT_DEV_IMAGE_DOCKER_BUILDX_LOCAL_CACHE_VERSION" {
  default = "${LOCAL_DOCKER_BUILDX_LOCAL_CACHE_DIR}/vault-dev-version"
}

variable "LOCAL_VAULT_DEV_IMAGE_DOCKER_BUILDX_LOCAL_CACHE_LATEST" {
  default = "${LOCAL_DOCKER_BUILDX_LOCAL_CACHE_DIR}/vault-dev-latest"
}

variable "LOCAL_VAULT_DEV_IMAGE_DOCKER_BUILDX_CACHE_WRITE_VERSION" {
  description = "local write cache for builder image build (version)"
  default     = "type=local,mode=max,dest=${LOCAL_VAULT_DEV_IMAGE_DOCKER_BUILDX_LOCAL_CACHE_VERSION}"
}

variable "LOCAL_VAULT_DEV_IMAGE_DOCKER_BUILDX_CACHE_WRITE_LATEST" {
  description = "local write cache for builder image build (latest)"
  default     = "type=local,mode=max,dest=${LOCAL_VAULT_DEV_IMAGE_DOCKER_BUILDX_LOCAL_CACHE_LATEST}"
}

variable "LOCAL_VAULT_DEV_IMAGE_DOCKER_BUILDX_LOCAL_CACHE_READ_VERSION" {
  description = "local read cache for builder image build (version)"
  default     = "type=local,src=${LOCAL_VAULT_DEV_IMAGE_DOCKER_BUILDX_LOCAL_CACHE_VERSION}"
}

variable "LOCAL_VAULT_DEV_IMAGE_DOCKER_BUILDX_LOCAL_CACHE_READ_LATEST" {
  description = "local read cache for builder image build (latest)"
  default     = "type=local,src=${LOCAL_VAULT_DEV_IMAGE_DOCKER_BUILDX_LOCAL_CACHE_LATEST}"
}

group "local-vault-dev-ci" {
  targets = [
    "local-vault-dev-version-ci",
    "local-vault-dev-latest-ci",
  ]
}

target "local-vault-dev-version-ci" {
  contexts = {
    debian = "docker-image://${LOCAL_DEBIAN_IMAGE_VERSION}"
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
    ENABLE_LOCAL_CACHE ? [
      LOCAL_VAULT_DEV_IMAGE_DOCKER_BUILDX_LOCAL_CACHE_READ_VERSION
    ] : [],
    ENABLE_LOCAL_CACHE ? [
      LOCAL_VAULT_DEV_IMAGE_DOCKER_BUILDX_LOCAL_CACHE_READ_VERSION
    ] : [],
    [
      "type=inline,ref=${LOCAL_VAULT_DEV_IMAGE_LATEST}"
    ]
  )
  cache-to = concat(
    ENABLE_LOCAL_CACHE ? [
      LOCAL_VAULT_DEV_IMAGE_DOCKER_BUILDX_CACHE_WRITE_VERSION
    ] : [],
  )
  platforms = platforms
}

target "local-vault-dev-latest-ci" {
  contexts = {
    debian = "docker-image://${LOCAL_DEBIAN_IMAGE_VERSION}"
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
    ENABLE_LOCAL_CACHE ? [
      LOCAL_VAULT_DEV_IMAGE_DOCKER_BUILDX_LOCAL_CACHE_READ_LATEST
    ] : [],
    [
      "type=inline,ref=${LOCAL_VAULT_DEV_IMAGE_LATEST}"
    ]
  )
  cache-to = concat(
    USE_REGISTRY_CACHE ? [
      "type=registry,ref=${LOCAL_VAULT_DEV_IMAGE_REGISTRY_CACHE},mode=max"
    ] : [],
    ENABLE_LOCAL_CACHE ? [
      LOCAL_VAULT_DEV_IMAGE_DOCKER_BUILDX_CACHE_WRITE_LATEST
    ] : [],
    [
      "type=inline"
    ]
  )
  platforms = platforms
}

target "local-vault-dev" {
  contexts = {
    debian = "docker-image://${LOCAL_DEBIAN_IMAGE_VERSION}"
  }
  context    = "${LOCAL_DIR}/vault-dev"
  dockerfile = "Dockerfile"
  tags = [
    LOCAL_VAULT_DEV_IMAGE_LATEST,
    LOCAL_VAULT_DEV_IMAGE_VERSION,
  ]
  cache-from = concat(
    USE_REGISTRY_CACHE ? [
      "type=registry,ref=${LOCAL_VAULT_DEV_IMAGE_REGISTRY_CACHE}"
    ] : [],
    ENABLE_LOCAL_CACHE ? [
      LOCAL_VAULT_DEV_IMAGE_DOCKER_BUILDX_LOCAL_CACHE_READ_LATEST
    ] : [],
    [
      "type=inline,ref=${LOCAL_VAULT_DEV_IMAGE_LATEST}"
    ]
  )
  cache-to = concat(
    ENABLE_LOCAL_CACHE ? [
      LOCAL_VAULT_DEV_IMAGE_DOCKER_BUILDX_CACHE_WRITE_LATEST
    ] : []
  )
}
