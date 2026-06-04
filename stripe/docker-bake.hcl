variable "LOCAL_STRIPE_IMAGE_VERSION" {
  default = "${VEGITO_LOCAL_PUBLIC_IMAGES_BASE_NAME}:stripe-${VERSION}"
}

variable "LOCAL_STRIPE_IMAGE_LATEST" {
  default = "${VEGITO_LOCAL_PUBLIC_IMAGES_BASE_NAME}:stripe-latest"
}

variable "LOCAL_STRIPE_IMAGE_REGISTRY_CACHE" {
  default = "${VEGITO_LOCAL_CACHE_IMAGES_BASE}/stripe"
}

variable "LOCAL_STRIPE_IMAGE_DOCKER_BUILDX_LOCAL_CACHE_VERSION" {
  default = "${VEGITO_DOCKER_BUILDX_LOCAL_CACHE_DIR}/stripe-version"
}

variable "LOCAL_STRIPE_IMAGE_DOCKER_BUILDX_LOCAL_CACHE_LATEST" {
  default = "${VEGITO_DOCKER_BUILDX_LOCAL_CACHE_DIR}/stripe-latest"
}

variable "LOCAL_STRIPE_IMAGE_DOCKER_BUILDX_CACHE_WRITE_VERSION" {
  default = "type=local,mode=max,dest=${LOCAL_STRIPE_IMAGE_DOCKER_BUILDX_LOCAL_CACHE_VERSION}"
}

variable "LOCAL_STRIPE_IMAGE_DOCKER_BUILDX_CACHE_WRITE_LATEST" {
  default = "type=local,mode=max,dest=${LOCAL_STRIPE_IMAGE_DOCKER_BUILDX_LOCAL_CACHE_LATEST}"
}

variable "LOCAL_STRIPE_IMAGE_DOCKER_BUILDX_LOCAL_CACHE_READ_VERSION" {
  default = "type=local,src=${LOCAL_STRIPE_IMAGE_DOCKER_BUILDX_LOCAL_CACHE_VERSION}"
}

variable "LOCAL_STRIPE_IMAGE_DOCKER_BUILDX_LOCAL_CACHE_READ_LATEST" {
  default = "type=local,src=${LOCAL_STRIPE_IMAGE_DOCKER_BUILDX_LOCAL_CACHE_LATEST}"
}

group "local-stripe-ci" {
  targets = [
    "local-stripe-version-ci",
    "local-stripe-latest-ci",
  ]
}


target "local-stripe-base" {
  context    = "${LOCAL_DIR}/stripe"
  dockerfile = "Dockerfile"
  args = {
    debian_version = "trixie"
  }
}

target "local-stripe-version-ci" {
  inherits = ["local-stripe-base"]
  contexts = {
    debian = "docker-image://${VEGITO_DOCKER_TRIXIE_DEBIAN_IMAGE_VERSION}"
  }
  tags = [
    LOCAL_STRIPE_IMAGE_VERSION,
  ]
  cache-from = concat(
    USE_REGISTRY_CACHE ? [
      "type=registry,ref=${LOCAL_STRIPE_IMAGE_REGISTRY_CACHE}"
    ] : [],
    ENABLE_LOCAL_CACHE ? [
      LOCAL_STRIPE_IMAGE_DOCKER_BUILDX_LOCAL_CACHE_READ_VERSION
    ] : [],
    [
      LOCAL_STRIPE_IMAGE_LATEST
    ]
  )
  cache-to = concat(
    ENABLE_LOCAL_CACHE ? [
      LOCAL_STRIPE_IMAGE_DOCKER_BUILDX_CACHE_WRITE_VERSION
    ] : [],
  )
  platforms = platforms
}

target "local-stripe-latest-ci" {
  inherits = ["local-stripe-base"]
  contexts = {
    debian = "docker-image://${VEGITO_DOCKER_TRIXIE_DEBIAN_IMAGE_LATEST}"
  }
  tags = [
    LOCAL_STRIPE_IMAGE_LATEST
  ]
  cache-from = concat(
    USE_REGISTRY_CACHE ? [
      "type=registry,ref=${LOCAL_STRIPE_IMAGE_REGISTRY_CACHE}"
    ] : [],
    ENABLE_LOCAL_CACHE ? [
      LOCAL_STRIPE_IMAGE_DOCKER_BUILDX_LOCAL_CACHE_READ_LATEST
    ] : [],
    [
      LOCAL_STRIPE_IMAGE_LATEST
    ]
  )
  cache-to = concat(
    USE_REGISTRY_CACHE ? [
      "type=registry,ref=${LOCAL_STRIPE_IMAGE_REGISTRY_CACHE},mode=max"
    ] : [],
    ENABLE_LOCAL_CACHE ? [
      LOCAL_STRIPE_IMAGE_DOCKER_BUILDX_CACHE_WRITE_LATEST
    ] : [],
    [
      "type=inline"
    ]
  )
  platforms = platforms
}

target "local-stripe" {
  inherits = ["local-stripe-base"]
  contexts = {
    debian = "docker-image://${VEGITO_DOCKER_TRIXIE_DEBIAN_IMAGE_VERSION}"
  }
  tags = [
    LOCAL_STRIPE_IMAGE_LATEST,
    LOCAL_STRIPE_IMAGE_VERSION,
  ]
  cache-from = concat(
    USE_REGISTRY_CACHE ? [
      "type=registry,ref=${LOCAL_STRIPE_IMAGE_REGISTRY_CACHE}"
    ] : [],
    ENABLE_LOCAL_CACHE ? [
      LOCAL_STRIPE_IMAGE_DOCKER_BUILDX_LOCAL_CACHE_READ_LATEST
    ] : [],
    [
      LOCAL_STRIPE_IMAGE_LATEST
    ]
  )
  cache-to = concat(
    ENABLE_LOCAL_CACHE ? [
      LOCAL_STRIPE_IMAGE_DOCKER_BUILDX_CACHE_WRITE_LATEST
    ] : []
  )
}
