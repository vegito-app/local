variable "VEGITO_DEBIAN_VERSION" {
  default = "${VEGITO_PUBLIC_IMAGES_BASE_NAME}:debian-${VERSION}"
}

variable "VEGITO_DEBIAN_IMAGE_REGISTRY_CACHE" {
  default = "${VEGITO_CACHE_IMAGES_BASE}/debian"
}

variable "VEGITO_DEBIAN_DIR" {
  default = "${VEGITO_DOCKER_DIR}/debian"
}

variable "VEGITO_DEBIAN_IMAGE_REGISTRY_CACHE" {
  default = "${VEGITO_CACHE_IMAGES_BASE}/debian"
}

variable "VEGITO_DEBIAN_IMAGE_DOCKER_BUILDX_LOCAL_CACHE" {
  default = "${VEGITO_DOCKER_BUILDX_LOCAL_CACHE_DIR}/debian"
}

variable "VEGITO_DEBIAN_IMAGE_DOCKER_BUILDX_LOCAL_CACHE_WRITE" {
  default = "type=local,mode=max,dest=${VEGITO_DEBIAN_IMAGE_DOCKER_BUILDX_LOCAL_CACHE}"
}

variable "VEGITO_DEBIAN_IMAGE_DOCKER_BUILDX_LOCAL_CACHE_READ" {
  default = "type=local,src=${VEGITO_DEBIAN_IMAGE_DOCKER_BUILDX_LOCAL_CACHE}"
}

variable "VEGITO_DEBIAN_IMAGE_LATEST" {
  default = "${VEGITO_PRIVATE_REPOSITORY}/debian:latest"
}

variable "VEGITO_DEBIAN_IMAGE_VERSION" {
  default = "${VEGITO_PRIVATE_REPOSITORY}/debian:${VERSION}"
}

group "vegito-debian-ci" {
  targets = [
    "vegito-debian-version-ci",
    "vegito-debian-latest-ci",

    "vegito-debian-desktop-x-ci",
    "vegito-debian-flutter-ci",
    "vegito-debian-python-ci",
  ]
}

target "vegito-debian-version-ci" {
  tags = [
    VEGITO_DEBIAN_IMAGE_VERSION,
  ]
  context = VEGITO_DEBIAN_DIR
  cache-from = concat(
    USE_REGISTRY_CACHE ? [
      "type=registry,ref=${VEGITO_DEBIAN_IMAGE_REGISTRY_CACHE}"
    ] : [],
    ENABLE_LOCAL_CACHE ? [
      VEGITO_DEBIAN_IMAGE_DOCKER_BUILDX_LOCAL_CACHE_READ
    ] : [],
    [
      "type=inline,ref=${VEGITO_DEBIAN_IMAGE_LATEST}"
    ]
  )
  cache-to = concat(
    ENABLE_LOCAL_CACHE ? [
      VEGITO_DEBIAN_IMAGE_DOCKER_BUILDX_LOCAL_CACHE_WRITE
    ] : [],
  )
  platforms = platforms
}

target "vegito-debian-latest-ci" {
  tags = [
    VEGITO_DEBIAN_IMAGE_LATEST,
  ]
  context = VEGITO_DEBIAN_DIR
  cache-from = concat(
    USE_REGISTRY_CACHE ? [
      "type=registry,ref=${VEGITO_DEBIAN_IMAGE_REGISTRY_CACHE}"
    ] : [],
    ENABLE_LOCAL_CACHE ? [
      VEGITO_DEBIAN_IMAGE_DOCKER_BUILDX_LOCAL_CACHE_READ
    ] : [],
    [
      "type=inline,ref=${VEGITO_DEBIAN_IMAGE_LATEST}"
    ]
  )
  cache-to = [
    USE_REGISTRY_CACHE ? "type=registry,ref=${VEGITO_DEBIAN_IMAGE_REGISTRY_CACHE},mode=max" : "",
    "type=inline"
  ]
  platforms = platforms
}

target "vegito-debian" {
  tags = [
    VEGITO_DEBIAN_IMAGE_LATEST,
  ]
  context = VEGITO_DEBIAN_DIR
  cache-from = concat(
    USE_REGISTRY_CACHE ? [
      "type=registry,ref=${VEGITO_DEBIAN_IMAGE_REGISTRY_CACHE}"
    ] : [],
    ENABLE_LOCAL_CACHE ? [
      VEGITO_DEBIAN_IMAGE_DOCKER_BUILDX_LOCAL_CACHE_READ
    ] : [],
    [
      "type=inline,ref=${VEGITO_DEBIAN_IMAGE_LATEST}"
    ]
  )
  cache-to = concat(
    ENABLE_LOCAL_CACHE ? [
      VEGITO_DEBIAN_IMAGE_DOCKER_BUILDX_LOCAL_CACHE_WRITE
    ] : []
  )
}

variable "VEGITO_DEBIAN_PYTHON_IMAGE_LATEST" {
  default = "${VEGITO_PRIVATE_REPOSITORY}/python:latest"
}

variable "VEGITO_DEBIAN_PYTHON_IMAGE_VERSION" {
  default = "${VEGITO_PRIVATE_REPOSITORY}/python:${VERSION}"
}

variable "VEGITO_DEBIAN_PYTHON_IMAGE_DOCKER_BUILDX_LOCAL_CACHE" {
  default = "${VEGITO_DOCKER_BUILDX_LOCAL_CACHE_DIR}/python"
}

variable "VEGITO_DEBIAN_PYTHON_IMAGE_DOCKER_BUILDX_LOCAL_CACHE_WRITE" {
  default = "type=local,mode=max,dest=${VEGITO_DEBIAN_PYTHON_IMAGE_DOCKER_BUILDX_LOCAL_CACHE}"
}

variable "VEGITO_DEBIAN_PYTHON_IMAGE_DOCKER_BUILDX_LOCAL_CACHE_READ" {
  default = "type=local,src=${VEGITO_DEBIAN_PYTHON_IMAGE_DOCKER_BUILDX_LOCAL_CACHE}"
}

group "vegito-debian-python-ci" {
  targets = [
    "vegito-debian-python-version-ci",
    "vegito-debian-python-latest-ci",
  ]
}

target "vegito-debian-python-version-ci" {
  tags = [
    VEGITO_DEBIAN_PYTHON_IMAGE_VERSION,
  ]
  contexts = {
    debian = "target:vegito-debian-version-ci"
  }
  context    = VEGITO_DEBIAN_DIR
  dockerfile = "python.Dockerfile"
  cache-from = concat(
    USE_REGISTRY_CACHE ? [
      "type=registry,ref=${VEGITO_DEBIAN_PYTHON_IMAGE_REGISTRY_CACHE}"
    ] : [],
    ENABLE_LOCAL_CACHE ? [
      VEGITO_DEBIAN_PYTHON_IMAGE_DOCKER_BUILDX_LOCAL_CACHE_READ
    ] : [],
    [
      "type=inline,ref=${VEGITO_DEBIAN_PYTHON_IMAGE_LATEST}"
    ]
  )
  cache-to = concat(
    ENABLE_LOCAL_CACHE ? [
      VEGITO_DEBIAN_PYTHON_IMAGE_DOCKER_BUILDX_LOCAL_CACHE_WRITE
    ] : [],
  )
  platforms = platforms
}

target "vegito-debian-python-latest-ci" {
  tags = [
    VEGITO_DEBIAN_PYTHON_IMAGE_LATEST,
  ]
  contexts = {
    debian = "target:vegito-debian-latest-ci"
  }
  context    = VEGITO_DEBIAN_DIR
  dockerfile = "python.Dockerfile"
  cache-from = concat(
    USE_REGISTRY_CACHE ? [
      "type=registry,ref=${VEGITO_DEBIAN_PYTHON_IMAGE_REGISTRY_CACHE}"
    ] : [],
    ENABLE_LOCAL_CACHE ? [
      VEGITO_DEBIAN_PYTHON_IMAGE_DOCKER_BUILDX_LOCAL_CACHE_READ
    ] : [],
    [
      "type=inline,ref=${VEGITO_DEBIAN_PYTHON_IMAGE_LATEST}"
    ]
  )
  cache-to = [
    USE_REGISTRY_CACHE ? "type=registry,ref=${VEGITO_DEBIAN_PYTHON_IMAGE_REGISTRY_CACHE},mode=max" : "",
    "type=inline"
  ]
  platforms = platforms
}

target "vegito-debian-python" {
  tags = [
    VEGITO_DEBIAN_PYTHON_IMAGE_LATEST,
    VEGITO_DEBIAN_PYTHON_IMAGE_VERSION,
  ]
  contexts = {
    debian = "target:debian"
  }
  context    = VEGITO_DEBIAN_DIR
  dockerfile = "python.Dockerfile"
  cache-from = concat(
    USE_REGISTRY_CACHE ? [
      "type=registry,ref=${VEGITO_DEBIAN_PYTHON_IMAGE_REGISTRY_CACHE}"
    ] : [],
    ENABLE_LOCAL_CACHE ? [
      VEGITO_DEBIAN_PYTHON_IMAGE_DOCKER_BUILDX_LOCAL_CACHE_READ
    ] : [],
    [
      "type=inline,ref=${VEGITO_DEBIAN_PYTHON_IMAGE_LATEST}"
    ]
  )
  cache-to = concat(
    ENABLE_LOCAL_CACHE ? [
      VEGITO_DEBIAN_PYTHON_IMAGE_DOCKER_BUILDX_LOCAL_CACHE_WRITE
    ] : []
  )
}
