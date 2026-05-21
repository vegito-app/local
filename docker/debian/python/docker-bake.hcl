variable "VEGITO_DOCKER_DEBIAN_PYTHON_DIR" {
  default = "${VEGITO_DOCKER_DEBIAN_DIR}/python"
}

variable "VEGITO_DOCKER_DEBIAN_PYTHON_IMAGE_REGISTRY_CACHE" {
  default = "${VEGITO_DOCKER_DEBIAN_IMAGE_REGISTRY_CACHE}-python"
}

variable "VEGITO_DOCKER_DEBIAN_PYTHON_IMAGE_DOCKER_BUILDX_LOCAL_CACHE" {
  default = "${VEGITO_DOCKER_DEBIAN_IMAGE_DOCKER_BUILDX_LOCAL_CACHE}-python"
}

variable "VEGITO_DOCKER_DEBIAN_PYTHON_IMAGE_LATEST" {
  default = "${VEGITO_PUBLIC_REPOSITORY}/debian-python:latest"
}

variable "VEGITO_DOCKER_DEBIAN_PYTHON_IMAGE_VERSION" {
  default = "${VEGITO_PUBLIC_REPOSITORY}/debian-python:${VERSION}"
}

variable "VEGITO_DOCKER_DEBIAN_PYTHON_IMAGE_DOCKER_BUILDX_LOCAL_CACHE" {
  default = "${VEGITO_DOCKER_DEBIAN_IMAGE_DOCKER_BUILDX_LOCAL_CACHE}-python"
}

variable "VEGITO_DOCKER_DEBIAN_PYTHON_IMAGE_DOCKER_BUILDX_LOCAL_CACHE_WRITE" {
  default = "type=local,mode=max,dest=${VEGITO_DOCKER_DEBIAN_PYTHON_IMAGE_DOCKER_BUILDX_LOCAL_CACHE}"
}

variable "VEGITO_DOCKER_DEBIAN_PYTHON_IMAGE_DOCKER_BUILDX_LOCAL_CACHE_READ" {
  default = "type=local,src=${VEGITO_DOCKER_DEBIAN_PYTHON_IMAGE_DOCKER_BUILDX_LOCAL_CACHE}"
}

group "vegito-debian-python-ci" {
  targets = [
    "vegito-debian-python-version-ci",
    "vegito-debian-python-latest-ci",
    "vegito-debian-python-desktop-x-version-ci",
    "vegito-debian-python-desktop-x-latest-ci",

    "vegito-trixie-debian-python-ci",
  ]
}

group "vegito-debian-python-ci" {
  targets = [
    "vegito-trixie-debian-python-ci",

    "vegito-debian-python-version-ci",
    "vegito-debian-python-latest-ci",

    "vegito-debian-python-desktop-x-ci",

    "vegito-debian-python-docker-desktop-x-ci",
  ]
}

group "vegito-debian-python-desktop-x-ci" {
  targets = [
    "vegito-debian-python-desktop-x-version-ci",
    "vegito-debian-python-desktop-x-latest-ci",
  ]
}

group "vegito-debian-python-docker-desktop-x-ci" {
  targets = [
    "vegito-debian-python-docker-desktop-x-version-ci",
    "vegito-debian-python-docker-desktop-x-latest-ci",
  ]
}

target "vegito-debian-python-base" {
  context = VEGITO_DOCKER_DEBIAN_PYTHON_DIR
}

target "vegito-debian-python-version-ci" {
  inherits = ["vegito-debian-python-base"]
  tags = [
    VEGITO_DOCKER_DEBIAN_PYTHON_IMAGE_VERSION,
  ]
  contexts = {
    debian = "target:vegito-debian-version-ci"
  }
  cache-from = concat(
    USE_REGISTRY_CACHE ? [
      "type=registry,ref=${VEGITO_DOCKER_DEBIAN_PYTHON_IMAGE_REGISTRY_CACHE}"
    ] : [],
    ENABLE_LOCAL_CACHE ? [
      VEGITO_DOCKER_DEBIAN_PYTHON_IMAGE_DOCKER_BUILDX_LOCAL_CACHE_READ
    ] : [],
    [
      VEGITO_DOCKER_DEBIAN_PYTHON_IMAGE_LATEST
    ]
  )
  cache-to = concat(
    ENABLE_LOCAL_CACHE ? [
      VEGITO_DOCKER_DEBIAN_PYTHON_IMAGE_DOCKER_BUILDX_LOCAL_CACHE_WRITE
    ] : [],
  )
  platforms = platforms
}

target "vegito-debian-python-latest-ci" {
  inherits = ["vegito-debian-python-base"]
  tags = [
    VEGITO_DOCKER_DEBIAN_PYTHON_IMAGE_LATEST,
  ]
  contexts = {
    debian = "target:vegito-debian-latest-ci"
  }
  cache-from = concat(
    USE_REGISTRY_CACHE ? [
      "type=registry,ref=${VEGITO_DOCKER_DEBIAN_PYTHON_IMAGE_REGISTRY_CACHE}"
    ] : [],
    ENABLE_LOCAL_CACHE ? [
      VEGITO_DOCKER_DEBIAN_PYTHON_IMAGE_DOCKER_BUILDX_LOCAL_CACHE_READ
    ] : [],
    [
      VEGITO_DOCKER_DEBIAN_PYTHON_IMAGE_LATEST
    ]
  )
  cache-to = [
    USE_REGISTRY_CACHE ? "type=registry,ref=${VEGITO_DOCKER_DEBIAN_PYTHON_IMAGE_REGISTRY_CACHE},mode=max" : "",
    "type=inline"
  ]
  platforms = platforms
}

target "vegito-debian-python" {
  inherits = ["vegito-debian-python-base"]
  tags = [
    VEGITO_DOCKER_DEBIAN_PYTHON_IMAGE_LATEST,
    VEGITO_DOCKER_DEBIAN_PYTHON_IMAGE_VERSION,
  ]
  contexts = {
    debian = "target:debian"
  }
  cache-from = concat(
    USE_REGISTRY_CACHE ? [
      "type=registry,ref=${VEGITO_DOCKER_DEBIAN_PYTHON_IMAGE_REGISTRY_CACHE}"
    ] : [],
    ENABLE_LOCAL_CACHE ? [
      VEGITO_DOCKER_DEBIAN_PYTHON_IMAGE_DOCKER_BUILDX_LOCAL_CACHE_READ
    ] : [],
    [
      VEGITO_DOCKER_DEBIAN_PYTHON_IMAGE_LATEST
    ]
  )
  cache-to = concat(
    ENABLE_LOCAL_CACHE ? [
      VEGITO_DOCKER_DEBIAN_PYTHON_IMAGE_DOCKER_BUILDX_LOCAL_CACHE_WRITE
    ] : []
  )
}

variable "VEGITO_DOCKER_DEBIAN_PYTHON_DESKTOP_X_IMAGE_VERSION" {
  default = "${VEGITO_DOCKER_PUBLIC_IMAGES_BASE_NAME}:debian-python-desktop-x-${VERSION}"
}

variable "VEGITO_DOCKER_DEBIAN_PYTHON_DESKTOP_X_IMAGE_LATEST" {
  default = "${VEGITO_DOCKER_PUBLIC_IMAGES_BASE_NAME}:debian-python-desktop-x-latest"
}
variable "VEGITO_DOCKER_DEBIAN_PYTHON_DESKTOP_X_IMAGE_DOCKER_BUILDX_LOCAL_CACHE" {
  default = "${VEGITO_DOCKER_DEBIAN_IMAGE_DOCKER_BUILDX_LOCAL_CACHE}-python"
}

variable "VEGITO_DOCKER_DEBIAN_PYTHON_DESKTOP_X_IMAGE_DOCKER_BUILDX_LOCAL_CACHE_WRITE" {
  default = "type=local,mode=max,dest=${VEGITO_DOCKER_DEBIAN_PYTHON_DESKTOP_X_IMAGE_DOCKER_BUILDX_LOCAL_CACHE}"
}

variable "VEGITO_DOCKER_DEBIAN_PYTHON_DESKTOP_X_IMAGE_DOCKER_BUILDX_LOCAL_CACHE_READ" {
  default = "type=local,src=${VEGITO_DOCKER_DEBIAN_PYTHON_DESKTOP_X_IMAGE_DOCKER_BUILDX_LOCAL_CACHE}"
}

variable "VEGITO_DOCKER_DEBIAN_PYTHON_DESKTOP_X_IMAGE_REGISTRY_CACHE" {
  default = "${VEGITO_DOCKER_DEBIAN_IMAGE_REGISTRY_CACHE}-python-desktop-x"
}

target "vegito-debian-python-desktop-x-version-ci" {
  contexts = {
    debian = "target:vegito-debian-desktop-x-version-ci"
  }
  inherits = ["vegito-debian-python-base"]
  tags = [
    VEGITO_DOCKER_DEBIAN_PYTHON_DESKTOP_X_IMAGE_VERSION,
  ]
  cache-from = concat(
    USE_REGISTRY_CACHE ? [
      "type=registry,ref=${VEGITO_DOCKER_DEBIAN_PYTHON_DESKTOP_X_IMAGE_REGISTRY_CACHE}"
    ] : [],
    ENABLE_LOCAL_CACHE ? [
      VEGITO_DOCKER_DEBIAN_PYTHON_DESKTOP_X_IMAGE_DOCKER_BUILDX_LOCAL_CACHE_READ
    ] : [],
    [
      VEGITO_DOCKER_DEBIAN_PYTHON_DESKTOP_X_IMAGE_LATEST
    ]
  )
  cache-to = concat(
    ENABLE_LOCAL_CACHE ? [
      VEGITO_DOCKER_DEBIAN_PYTHON_DESKTOP_X_IMAGE_DOCKER_BUILDX_LOCAL_CACHE_WRITE
    ] : [],
  )
  platforms = platforms
}

target "vegito-debian-python-desktop-x-latest-ci" {
  inherits = ["vegito-debian-python-base"]
  contexts = {
    debian = "target:vegito-debian-desktop-x-latest-ci"
  }
  tags = [
    VEGITO_DOCKER_DEBIAN_PYTHON_DESKTOP_X_IMAGE_LATEST,
  ]
  cache-from = concat(
    USE_REGISTRY_CACHE ? [
      "type=registry,ref=${VEGITO_DOCKER_DEBIAN_PYTHON_DESKTOP_X_IMAGE_REGISTRY_CACHE}"
    ] : [],
    ENABLE_LOCAL_CACHE ? [
      VEGITO_DOCKER_DEBIAN_PYTHON_DESKTOP_X_IMAGE_DOCKER_BUILDX_LOCAL_CACHE_READ
    ] : [],
    [
      VEGITO_DOCKER_DEBIAN_PYTHON_DESKTOP_X_IMAGE_LATEST
    ]
  )
  cache-to = [
    USE_REGISTRY_CACHE ? "type=registry,ref=${VEGITO_DOCKER_DEBIAN_PYTHON_DESKTOP_X_IMAGE_REGISTRY_CACHE},mode=max" : "",
    "type=inline"
  ]
  platforms = platforms
}

target "vegito-debian-python-desktop-x" {
  inherits = ["vegito-debian-python-base"]
  contexts = {
    debian = "target:vegito-debian-desktop-x-version-ci"
  }
  tags = [
    VEGITO_DOCKER_DEBIAN_PYTHON_DESKTOP_X_IMAGE_VERSION,
    VEGITO_DOCKER_DEBIAN_PYTHON_DESKTOP_X_IMAGE_LATEST,
  ]
  cache-from = concat(
    USE_REGISTRY_CACHE ? [
      "type=registry,ref=${VEGITO_DOCKER_DEBIAN_PYTHON_DESKTOP_X_IMAGE_REGISTRY_CACHE}"
    ] : [],
    ENABLE_LOCAL_CACHE ? [
      VEGITO_DOCKER_DEBIAN_PYTHON_DESKTOP_X_IMAGE_DOCKER_BUILDX_LOCAL_CACHE_READ
    ] : [],
    [
      VEGITO_DOCKER_DEBIAN_PYTHON_DESKTOP_X_IMAGE_LATEST
    ]
  )
  cache-to = concat(
    ENABLE_LOCAL_CACHE ? [
      VEGITO_DOCKER_DEBIAN_PYTHON_DESKTOP_X_IMAGE_DOCKER_BUILDX_LOCAL_CACHE_WRITE
    ] : []
  )
}
