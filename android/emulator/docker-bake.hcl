# -------------------------------------------------------------------
# ###################################################################
# LOCAL ANDROID EMULATOR
# ###################################################################
variable "LOCAL_ANDROID_EMULATOR_VERSION" {
  default = "${VEGITO_LOCAL_PUBLIC_IMAGES_BASE_NAME}:android-emulator-${VERSION}"
}

variable "LOCAL_ANDROID_EMULATOR_IMAGE_REGISTRY_CACHE" {
  default = "${VEGITO_LOCAL_CACHE_IMAGES_BASE}/local-android-emulator"
}

variable "LOCAL_ANDROID_EMULATOR_DIR" {
  default = "${LOCAL_ANDROID_DIR}/emulator"
}

variable "LOCAL_ANDROID_EMULATOR_IMAGE_DOCKER_BUILDX_LOCAL_CACHE_VERSION" {
  default = "${VEGITO_DOCKER_BUILDX_LOCAL_CACHE_DIR}/android-emulator-version"
}

variable "LOCAL_ANDROID_EMULATOR_IMAGE_DOCKER_BUILDX_LOCAL_CACHE_LATEST" {
  default = "${VEGITO_DOCKER_BUILDX_LOCAL_CACHE_DIR}/android-emulator-latest"
}

variable "LOCAL_ANDROID_EMULATOR_IMAGE_DOCKER_BUILDX_CACHE_WRITE_VERSION" {
  description = "local write cache for local-android-emulator version image build"
  default     = "type=local,mode=max,dest=${LOCAL_ANDROID_EMULATOR_IMAGE_DOCKER_BUILDX_LOCAL_CACHE_VERSION}"
}

variable "LOCAL_ANDROID_EMULATOR_IMAGE_DOCKER_BUILDX_CACHE_WRITE_LATEST" {
  description = "local write cache for local-android-emulator latest image build"
  default     = "type=local,mode=max,dest=${LOCAL_ANDROID_EMULATOR_IMAGE_DOCKER_BUILDX_LOCAL_CACHE_LATEST}"
}

variable "LOCAL_ANDROID_EMULATOR_IMAGE_DOCKER_BUILDX_LOCAL_CACHE_READ_VERSION" {
  description = "local read cache for local-android-emulator version image build (cannot be used before first write)"
  default     = "type=local,src=${LOCAL_ANDROID_EMULATOR_IMAGE_DOCKER_BUILDX_LOCAL_CACHE_VERSION}"
}

variable "LOCAL_ANDROID_EMULATOR_IMAGE_DOCKER_BUILDX_LOCAL_CACHE_READ_LATEST" {
  description = "local read cache for local-android-emulator latest image build (cannot be used before first write)"
  default     = "type=local,src=${LOCAL_ANDROID_EMULATOR_IMAGE_DOCKER_BUILDX_LOCAL_CACHE_LATEST}"
}

variable "LOCAL_ANDROID_EMULATOR_IMAGE_LATEST" {
  default = "${VEGITO_LOCAL_PUBLIC_IMAGES_BASE_NAME}:android-emulator-latest"
}

variable "LOCAL_ANDROID_EMULATOR_IMAGE_VERSION" {
  default = "${VEGITO_LOCAL_PUBLIC_IMAGES_BASE_NAME}:android-emulator-${VERSION}"
}

group "local-android-emulator-ci" {
  description = "Build and push Android Emmulator images"
  targets = [
    "local-android-emulator-version-ci",
    "local-android-emulator-latest-ci",
  ]
}

target "local-android-emulator-base" {
  context = LOCAL_ANDROID_EMULATOR_DIR
}

target "local-android-emulator-version-ci" {
  inherits = ["local-android-emulator-base"]
  contexts = {
    debian = "docker-image://${VEGITO_DOCKER_TRIXIE_DEBIAN_DESKTOP_X_IMAGE_VERSION}"
  }
  tags = [
    LOCAL_ANDROID_EMULATOR_IMAGE_VERSION,
  ]
  cache-from = concat(
    USE_REGISTRY_CACHE ? [
      "type=registry,ref=${LOCAL_ANDROID_EMULATOR_IMAGE_REGISTRY_CACHE}",
      "type=registry,ref=${VEGITO_DOCKER_TRIXIE_DEBIAN_IMAGE_REGISTRY_CACHE}"
    ] : [],
    ENABLE_LOCAL_CACHE ? [
      LOCAL_ANDROID_EMULATOR_IMAGE_DOCKER_BUILDX_LOCAL_CACHE_READ_VERSION
    ] : [],
    [
      "type=inline,ref=${VEGITO_DOCKER_TRIXIE_DEBIAN_DESKTOP_X_IMAGE_LATEST}"
    ]
  )
  cache-to = concat(
    ENABLE_LOCAL_CACHE ? [
      LOCAL_ANDROID_EMULATOR_IMAGE_DOCKER_BUILDX_CACHE_WRITE_VERSION
    ] : []
  )
  platforms = platforms
}

target "local-android-emulator-latest-ci" {
  inherits = ["local-android-emulator-base"]
  contexts = {
    debian = "docker-image://${VEGITO_DOCKER_TRIXIE_DEBIAN_DESKTOP_X_IMAGE_LATEST}"
  }
  tags = [
    LOCAL_ANDROID_EMULATOR_IMAGE_LATEST,
  ]
  cache-from = concat(
    USE_REGISTRY_CACHE ? [
      "type=registry,ref=${LOCAL_ANDROID_EMULATOR_IMAGE_REGISTRY_CACHE}",
      "type=registry,ref=${VEGITO_DOCKER_TRIXIE_DEBIAN_IMAGE_REGISTRY_CACHE}",
    ] : [],
    ENABLE_LOCAL_CACHE ? [
      LOCAL_ANDROID_EMULATOR_IMAGE_DOCKER_BUILDX_LOCAL_CACHE_READ_LATEST
    ] : [],
    [
      "type=inline,ref=${LOCAL_ANDROID_EMULATOR_IMAGE_LATEST}",
      "type=inline,ref=${VEGITO_DOCKER_TRIXIE_DEBIAN_DESKTOP_X_IMAGE_LATEST}"
    ]
  )
  cache-to = concat(
    USE_REGISTRY_CACHE ? [
      "type=registry,ref=${LOCAL_ANDROID_EMULATOR_IMAGE_REGISTRY_CACHE},mode=max"
    ] : [],
    ENABLE_LOCAL_CACHE ? [
      LOCAL_ANDROID_EMULATOR_IMAGE_DOCKER_BUILDX_CACHE_WRITE_LATEST
    ] : [],
    [
      "type=inline"
    ]
  )
  platforms = platforms
}

target "local-android-emulator" {
  inherits = ["local-android-emulator-base"]
  contexts = {
    debian = "docker-image://${VEGITO_DOCKER_TRIXIE_DEBIAN_DESKTOP_X_IMAGE_VERSION}"
  }
  tags = [
    LOCAL_ANDROID_EMULATOR_IMAGE_LATEST,
    LOCAL_ANDROID_EMULATOR_IMAGE_VERSION,
  ]
  cache-from = concat(
    USE_REGISTRY_CACHE ? [
      "type=registry,ref=${LOCAL_ANDROID_EMULATOR_IMAGE_REGISTRY_CACHE}",
      "type=registry,ref=${VEGITO_DOCKER_TRIXIE_DEBIAN_IMAGE_REGISTRY_CACHE}"
    ] : [],
    ENABLE_LOCAL_CACHE ? [
      LOCAL_ANDROID_EMULATOR_IMAGE_DOCKER_BUILDX_LOCAL_CACHE_READ_LATEST
    ] : [],
    [
      "type=inline,ref=${LOCAL_ANDROID_EMULATOR_IMAGE_LATEST}",
      "type=inline,ref=${VEGITO_DOCKER_TRIXIE_DEBIAN_DESKTOP_X_IMAGE_LATEST}"
    ]
  )
  cache-to = concat(
    ENABLE_LOCAL_CACHE ? [
      LOCAL_ANDROID_EMULATOR_IMAGE_DOCKER_BUILDX_CACHE_WRITE_LATEST
    ] : []
  )
}
# -------------------------------------------------------------------
# ###################################################################
# LOCAL ANDROID EMULATOR FLUTTER
# ###################################################################
variable "LOCAL_ANDROID_EMULATOR_FLUTTER_REGISTRY_CACHE_IMAGE" {
  default = "${VEGITO_LOCAL_CACHE_IMAGES_BASE}/android-emulator-flutter"
}

variable "LOCAL_ANDROID_EMULATOR_FLUTTER_IMAGE_REGISTRY_CACHE" {
  default = "${VEGITO_LOCAL_CACHE_IMAGES_BASE}/android-emulator-flutter"
}

variable "LOCAL_ANDROID_EMULATOR_FLUTTER_IMAGE_VERSION" {
  default = "${VEGITO_LOCAL_PUBLIC_IMAGES_BASE_NAME}:android-flutter-${VERSION}"
}

variable "LOCAL_ANDROID_EMULATOR_FLUTTER_IMAGE_LATEST" {
  default = "${VEGITO_LOCAL_PUBLIC_IMAGES_BASE_NAME}:android-flutter-latest"
}

variable "LOCAL_ANDROID_EMULATOR_FLUTTER_IMAGE_DOCKER_BUILDX_LOCAL_CACHE_VERSION" {
  default = "${VEGITO_DOCKER_BUILDX_LOCAL_CACHE_DIR}/android-flutter-version"
}

variable "LOCAL_ANDROID_EMULATOR_FLUTTER_IMAGE_DOCKER_BUILDX_LOCAL_CACHE_LATEST" {
  default = "${VEGITO_DOCKER_BUILDX_LOCAL_CACHE_DIR}/android-flutter-latest"
}

variable "LOCAL_ANDROID_EMULATOR_FLUTTER_IMAGE_DOCKER_BUILDX_CACHE_WRITE_VERSION" {
  description = "local write cache (version) for local-flutter image build"
  default     = "type=local,mode=max,dest=${LOCAL_ANDROID_EMULATOR_FLUTTER_IMAGE_DOCKER_BUILDX_LOCAL_CACHE_VERSION}"
}

variable "LOCAL_ANDROID_EMULATOR_FLUTTER_IMAGE_DOCKER_BUILDX_CACHE_WRITE_LATEST" {
  description = "local write cache (latest) for local-flutter image build"
  default     = "type=local,mode=max,dest=${LOCAL_ANDROID_EMULATOR_FLUTTER_IMAGE_DOCKER_BUILDX_LOCAL_CACHE_LATEST}"
}

variable "LOCAL_ANDROID_EMULATOR_FLUTTER_IMAGE_DOCKER_BUILDX_LOCAL_CACHE_READ_VERSION" {
  description = "local read cache (version)"
  default     = "type=local,src=${LOCAL_ANDROID_EMULATOR_FLUTTER_IMAGE_DOCKER_BUILDX_LOCAL_CACHE_VERSION}"
}

variable "LOCAL_ANDROID_EMULATOR_FLUTTER_IMAGE_DOCKER_BUILDX_LOCAL_CACHE_READ_LATEST" {
  description = "local read cache (latest)"
  default     = "type=local,src=${LOCAL_ANDROID_EMULATOR_FLUTTER_IMAGE_DOCKER_BUILDX_LOCAL_CACHE_LATEST}"
}

target "local-android-emulator-flutter-latest-ci" {
  inherits = ["local-android-emulator-base"]
  contexts = {
    debian = "docker-image://${VEGITO_DOCKER_TRIXIE_DEBIAN_FLUTTER_DESKTOP_X_IMAGE_LATEST}"
  }
  tags = [
    LOCAL_ANDROID_EMULATOR_FLUTTER_IMAGE_LATEST,
  ]
  cache-from = concat(
    USE_REGISTRY_CACHE ? [
      "type=registry,ref=${LOCAL_ANDROID_EMULATOR_FLUTTER_IMAGE_REGISTRY_CACHE}",
    ] : [],
    ENABLE_LOCAL_CACHE ? [
      LOCAL_ANDROID_EMULATOR_FLUTTER_IMAGE_DOCKER_BUILDX_LOCAL_CACHE_READ_LATEST
    ] : [],
    [
      "type=inline,ref=${LOCAL_ANDROID_EMULATOR_FLUTTER_IMAGE_LATEST}",
    ]
  )
  cache-to = concat(
    USE_REGISTRY_CACHE ? [
      "type=registry,ref=${LOCAL_ANDROID_EMULATOR_FLUTTER_IMAGE_REGISTRY_CACHE},mode=max"
    ] : [],
    ENABLE_LOCAL_CACHE ? [
      LOCAL_ANDROID_EMULATOR_FLUTTER_IMAGE_DOCKER_BUILDX_CACHE_WRITE_LATEST
    ] : [],
    [
      "type=inline"
    ]
  )
  platforms = platforms
}

target "local-android-emulator-flutter-version-ci" {
  inherits = ["local-android-emulator-base"]
  contexts = {
    debian = "docker-image://${VEGITO_DOCKER_TRIXIE_DEBIAN_FLUTTER_DESKTOP_X_IMAGE_VERSION}"
  }
  tags = [
    LOCAL_ANDROID_EMULATOR_FLUTTER_IMAGE_VERSION,
  ]
  cache-from = concat(
    USE_REGISTRY_CACHE ? [
      "type=registry,ref=${LOCAL_ANDROID_EMULATOR_FLUTTER_IMAGE_REGISTRY_CACHE}",
    ] : [],
    ENABLE_LOCAL_CACHE ? [
      LOCAL_ANDROID_EMULATOR_FLUTTER_IMAGE_DOCKER_BUILDX_LOCAL_CACHE_READ_VERSION
    ] : [],
    [
      "type=inline,ref=${LOCAL_ANDROID_EMULATOR_FLUTTER_IMAGE_LATEST}",
    ]
  )
  cache-to = concat(
    ENABLE_LOCAL_CACHE ? [
      LOCAL_ANDROID_EMULATOR_FLUTTER_IMAGE_DOCKER_BUILDX_CACHE_WRITE_VERSION
    ] : []
  )
}

target "local-android-emulator-flutter" {
  inherits = ["local-android-emulator-base"]
  contexts = {
    debian = "docker-image://${VEGITO_DOCKER_TRIXIE_DEBIAN_FLUTTER_DESKTOP_X_IMAGE_LATEST}"
  }
  tags = [
    LOCAL_ANDROID_EMULATOR_FLUTTER_IMAGE_LATEST,
    LOCAL_ANDROID_EMULATOR_FLUTTER_IMAGE_VERSION,
  ]
  cache-from = concat(
    USE_REGISTRY_CACHE ? [
      "type=registry,ref=${LOCAL_ANDROID_EMULATOR_FLUTTER_IMAGE_REGISTRY_CACHE}",
    ] : [],
    ENABLE_LOCAL_CACHE ? [
      LOCAL_ANDROID_EMULATOR_FLUTTER_IMAGE_DOCKER_BUILDX_LOCAL_CACHE_READ_LATEST
    ] : [],
    [
      "type=inline,ref=${LOCAL_ANDROID_EMULATOR_FLUTTER_IMAGE_LATEST}",
    ]
  )
  cache-to = concat(
    ENABLE_LOCAL_CACHE ? [
      LOCAL_ANDROID_EMULATOR_FLUTTER_IMAGE_DOCKER_BUILDX_CACHE_WRITE_LATEST
    ] : []
  )
}
