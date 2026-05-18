variable "VEGITO_DOCKER_TRIXIE_DEBIAN_PYTHON_DIR" {
  default = "${VEGITO_DOCKER_DEBIAN_DIR}/python"
}

variable "VEGITO_DOCKER_TRIXIE_DEBIAN_PYTHON_IMAGE_REGISTRY_CACHE" {
  default = "${VEGITO_DOCKER_TRIXIE_DEBIAN_IMAGE_REGISTRY_CACHE}-python"
}

variable "VEGITO_DOCKER_TRIXIE_DEBIAN_PYTHON_IMAGE_LATEST" {
  default = "${VEGITO_PUBLIC_REPOSITORY}/trixie-debian-python:latest"
}

variable "VEGITO_DOCKER_TRIXIE_DEBIAN_PYTHON_IMAGE_VERSION" {
  default = "${VEGITO_PUBLIC_REPOSITORY}/trixie-debian-python:${VERSION}"
}

variable "VEGITO_DOCKER_TRIXIE_DEBIAN_PYTHON_IMAGE_DOCKER_BUILDX_LOCAL_CACHE" {
  default = "${VEGITO_DOCKER_TRIXIE_DEBIAN_IMAGE_DOCKER_BUILDX_LOCAL_CACHE}-python"
}

variable "VEGITO_DOCKER_TRIXIE_DEBIAN_PYTHON_IMAGE_DOCKER_BUILDX_LOCAL_CACHE_WRITE" {
  default = "type=local,mode=max,dest=${VEGITO_DOCKER_TRIXIE_DEBIAN_PYTHON_IMAGE_DOCKER_BUILDX_LOCAL_CACHE}"
}

variable "VEGITO_DOCKER_TRIXIE_DEBIAN_PYTHON_IMAGE_DOCKER_BUILDX_LOCAL_CACHE_READ" {
  default = "type=local,src=${VEGITO_DOCKER_TRIXIE_DEBIAN_PYTHON_IMAGE_DOCKER_BUILDX_LOCAL_CACHE}"
}


group "vegito-trixie-debian-python-ci" {
  targets = [
    "vegito-trixie-debian-python-version-ci",
    "vegito-trixie-debian-python-latest-ci",
    "vegito-trixie-debian-python-desktop-x-version-ci",
    "vegito-trixie-debian-python-desktop-x-latest-ci",
  ]
}

group "vegito-trixie-debian-python-ci" {
  targets = [
    "vegito-trixie-debian-python-version-ci",
    "vegito-trixie-debian-python-latest-ci",
    "vegito-trixie-debian-python-desktop-x-version-ci",
    "vegito-trixie-debian-python-desktop-x-latest-ci",
  ]
}

target "vegito-trixie-debian-python-base" {
  context = VEGITO_DOCKER_TRIXIE_DEBIAN_PYTHON_DIR
  args = {
    debian_version = "trixie"
  }
}

target "vegito-trixie-debian-python-version-ci" {
  inherits = ["vegito-trixie-debian-python-base"]
  tags = [
    VEGITO_DOCKER_TRIXIE_DEBIAN_PYTHON_IMAGE_VERSION,
  ]
  contexts = {
    debian = "target:vegito-trixie-debian-version-ci"
  }
  cache-from = concat(
    USE_REGISTRY_CACHE ? [
      "type=registry,ref=${VEGITO_DOCKER_TRIXIE_DEBIAN_PYTHON_IMAGE_REGISTRY_CACHE}"
    ] : [],
    ENABLE_LOCAL_CACHE ? [
      VEGITO_DOCKER_TRIXIE_DEBIAN_PYTHON_IMAGE_DOCKER_BUILDX_LOCAL_CACHE_READ
    ] : [],
    [
      "type=inline,ref=${VEGITO_DOCKER_TRIXIE_DEBIAN_PYTHON_IMAGE_LATEST}"
    ]
  )
  cache-to = concat(
    ENABLE_LOCAL_CACHE ? [
      VEGITO_DOCKER_TRIXIE_DEBIAN_PYTHON_IMAGE_DOCKER_BUILDX_LOCAL_CACHE_WRITE
    ] : [],
  )
  platforms = platforms
}

target "vegito-trixie-debian-python-latest-ci" {
  inherits = ["vegito-trixie-debian-python-base"]
  tags = [
    VEGITO_DOCKER_TRIXIE_DEBIAN_PYTHON_IMAGE_LATEST,
  ]
  contexts = {
    debian = "target:vegito-trixie-debian-latest-ci"
  }
  cache-from = concat(
    USE_REGISTRY_CACHE ? [
      "type=registry,ref=${VEGITO_DOCKER_TRIXIE_DEBIAN_PYTHON_IMAGE_REGISTRY_CACHE}"
    ] : [],
    ENABLE_LOCAL_CACHE ? [
      VEGITO_DOCKER_TRIXIE_DEBIAN_PYTHON_IMAGE_DOCKER_BUILDX_LOCAL_CACHE_READ
    ] : [],
    [
      "type=inline,ref=${VEGITO_DOCKER_TRIXIE_DEBIAN_PYTHON_IMAGE_LATEST}"
    ]
  )
  cache-to = [
    USE_REGISTRY_CACHE ? "type=registry,ref=${VEGITO_DOCKER_TRIXIE_DEBIAN_PYTHON_IMAGE_REGISTRY_CACHE},mode=max" : "",
    "type=inline"
  ]
  platforms = platforms
}

target "vegito-trixie-debian-python" {
  inherits = ["vegito-trixie-debian-python-base"]
  tags = [
    VEGITO_DOCKER_TRIXIE_DEBIAN_PYTHON_IMAGE_LATEST,
    VEGITO_DOCKER_TRIXIE_DEBIAN_PYTHON_IMAGE_VERSION,
  ]
  contexts = {
    debian = "target:debian"
  }
  cache-from = concat(
    USE_REGISTRY_CACHE ? [
      "type=registry,ref=${VEGITO_DOCKER_TRIXIE_DEBIAN_PYTHON_IMAGE_REGISTRY_CACHE}"
    ] : [],
    ENABLE_LOCAL_CACHE ? [
      VEGITO_DOCKER_TRIXIE_DEBIAN_PYTHON_IMAGE_DOCKER_BUILDX_LOCAL_CACHE_READ
    ] : [],
    [
      "type=inline,ref=${VEGITO_DOCKER_TRIXIE_DEBIAN_PYTHON_IMAGE_LATEST}"
    ]
  )
  cache-to = concat(
    ENABLE_LOCAL_CACHE ? [
      VEGITO_DOCKER_TRIXIE_DEBIAN_PYTHON_IMAGE_DOCKER_BUILDX_LOCAL_CACHE_WRITE
    ] : []
  )
}

variable "VEGITO_DOCKER_TRIXIE_DEBIAN_PYTHON_DESKTOP_X_IMAGE_VERSION" {
  default = "${VEGITO_PUBLIC_IMAGES_BASE_NAME}:trixie-debian-python-desktop-x-${VERSION}"
}

variable "VEGITO_DOCKER_TRIXIE_DEBIAN_PYTHON_DESKTOP_X_IMAGE_LATEST" {
  default = "${VEGITO_PUBLIC_IMAGES_BASE_NAME}:trixie-debian-python-desktop-x-latest"
}
variable "VEGITO_DOCKER_TRIXIE_DEBIAN_PYTHON_DESKTOP_X_IMAGE_DOCKER_BUILDX_LOCAL_CACHE" {
  default = "${VEGITO_DOCKER_TRIXIE_DEBIAN_IMAGE_DOCKER_BUILDX_LOCAL_CACHE}-python"
}

variable "VEGITO_DOCKER_TRIXIE_DEBIAN_PYTHON_DESKTOP_X_IMAGE_DOCKER_BUILDX_LOCAL_CACHE_WRITE" {
  default = "type=local,mode=max,dest=${VEGITO_DOCKER_TRIXIE_DEBIAN_PYTHON_DESKTOP_X_IMAGE_DOCKER_BUILDX_LOCAL_CACHE}"
}

variable "VEGITO_DOCKER_TRIXIE_DEBIAN_PYTHON_DESKTOP_X_IMAGE_DOCKER_BUILDX_LOCAL_CACHE_READ" {
  default = "type=local,src=${VEGITO_DOCKER_TRIXIE_DEBIAN_PYTHON_DESKTOP_X_IMAGE_DOCKER_BUILDX_LOCAL_CACHE}"
}

variable "VEGITO_DOCKER_TRIXIE_DEBIAN_PYTHON_DESKTOP_X_IMAGE_REGISTRY_CACHE" {
  default = "${VEGITO_DOCKER_TRIXIE_DEBIAN_IMAGE_REGISTRY_CACHE}-python-desktop-x"
}

target "vegito-trixie-debian-python-desktop-x-version-ci" {
  contexts = {
    debian = "target:vegito-trixie-debian-desktop-x-version-ci"
  }
  inherits = ["vegito-trixie-debian-python-base"]
  tags = [
    VEGITO_DOCKER_TRIXIE_DEBIAN_PYTHON_DESKTOP_X_IMAGE_VERSION,
  ]
  cache-from = concat(
    USE_REGISTRY_CACHE ? [
      "type=registry,ref=${VEGITO_DOCKER_TRIXIE_DEBIAN_PYTHON_DESKTOP_X_IMAGE_REGISTRY_CACHE}"
    ] : [],
    ENABLE_LOCAL_CACHE ? [
      VEGITO_DOCKER_TRIXIE_DEBIAN_PYTHON_DESKTOP_X_IMAGE_DOCKER_BUILDX_LOCAL_CACHE_READ
    ] : [],
    [
      "type=inline,ref=${VEGITO_DOCKER_TRIXIE_DEBIAN_PYTHON_DESKTOP_X_IMAGE_LATEST}"
    ]
  )
  cache-to = concat(
    ENABLE_LOCAL_CACHE ? [
      VEGITO_DOCKER_TRIXIE_DEBIAN_PYTHON_DESKTOP_X_IMAGE_DOCKER_BUILDX_LOCAL_CACHE_WRITE
    ] : [],
  )
  platforms = platforms
}

target "vegito-trixie-debian-python-desktop-x-latest-ci" {
  inherits = ["vegito-trixie-debian-python-base"]
  contexts = {
    debian = "target:vegito-trixie-debian-desktop-x-latest-ci"
  }
  tags = [
    VEGITO_DOCKER_TRIXIE_DEBIAN_PYTHON_DESKTOP_X_IMAGE_LATEST,
  ]
  cache-from = concat(
    USE_REGISTRY_CACHE ? [
      "type=registry,ref=${VEGITO_DOCKER_TRIXIE_DEBIAN_PYTHON_DESKTOP_X_IMAGE_REGISTRY_CACHE}"
    ] : [],
    ENABLE_LOCAL_CACHE ? [
      VEGITO_DOCKER_TRIXIE_DEBIAN_PYTHON_DESKTOP_X_IMAGE_DOCKER_BUILDX_LOCAL_CACHE_READ
    ] : [],
    [
      "type=inline,ref=${VEGITO_DOCKER_TRIXIE_DEBIAN_PYTHON_DESKTOP_X_IMAGE_LATEST}"
    ]
  )
  cache-to = [
    USE_REGISTRY_CACHE ? "type=registry,ref=${VEGITO_DOCKER_TRIXIE_DEBIAN_PYTHON_DESKTOP_X_IMAGE_REGISTRY_CACHE},mode=max" : "",
    "type=inline"
  ]
  platforms = platforms
}

target "vegito-trixie-debian-python-desktop-x" {
  inherits = ["vegito-trixie-debian-python-base"]
  contexts = {
    debian = "target:vegito-trixie-debian-desktop-x-version-ci"
  }
  tags = [
    VEGITO_DOCKER_TRIXIE_DEBIAN_PYTHON_DESKTOP_X_IMAGE_VERSION,
    VEGITO_DOCKER_TRIXIE_DEBIAN_PYTHON_DESKTOP_X_IMAGE_LATEST,
  ]
  cache-from = concat(
    USE_REGISTRY_CACHE ? [
      "type=registry,ref=${VEGITO_DOCKER_TRIXIE_DEBIAN_PYTHON_DESKTOP_X_IMAGE_REGISTRY_CACHE}"
    ] : [],
    ENABLE_LOCAL_CACHE ? [
      VEGITO_DOCKER_TRIXIE_DEBIAN_PYTHON_DESKTOP_X_IMAGE_DOCKER_BUILDX_LOCAL_CACHE_READ
    ] : [],
    [
      "type=inline,ref=${VEGITO_DOCKER_TRIXIE_DEBIAN_PYTHON_DESKTOP_X_IMAGE_LATEST}"
    ]
  )
  cache-to = concat(
    ENABLE_LOCAL_CACHE ? [
      VEGITO_DOCKER_TRIXIE_DEBIAN_PYTHON_DESKTOP_X_IMAGE_DOCKER_BUILDX_LOCAL_CACHE_WRITE
    ] : []
  )
}
