variable "LOCAL_ANDROID_FLUTTER_VERSION" {
  default = "${VEGITO_LOCAL_PUBLIC_IMAGES_BASE}:android-flutter-${VERSION}"
}

variable "LOCAL_ANDROID_FLUTTER_IMAGE_LATEST" {
  default = "${VEGITO_LOCAL_PUBLIC_IMAGES_BASE}:android-flutter-latest"
}

variable "LOCAL_ANDROID_FLUTTER_REGISTRY_CACHE_IMAGE" {
  default = "${VEGITO_LOCAL_CACHE_IMAGES_BASE}/android-flutter"
}

variable "LOCAL_ANDROID_FLUTTER_IMAGE_REGISTRY_CACHE" {
  default = "${VEGITO_LOCAL_CACHE_IMAGES_BASE}/android-flutter"
}

variable "LOCAL_ANDROID_FLUTTER_DIR" {
  default = "${LOCAL_ANDROID_DIR}/flutter"
}

variable "LOCAL_ANDROID_FLUTTER_IMAGE_DOCKER_BUILDX_LOCAL_CACHE_VERSION" {
  default = "${LOCAL_DOCKER_BUILDX_LOCAL_CACHE_DIR}/android-flutter-version"
}

variable "LOCAL_ANDROID_FLUTTER_IMAGE_DOCKER_BUILDX_LOCAL_CACHE_LATEST" {
  default = "${LOCAL_DOCKER_BUILDX_LOCAL_CACHE_DIR}/android-flutter-latest"
}

variable "LOCAL_ANDROID_FLUTTER_IMAGE_DOCKER_BUILDX_CACHE_WRITE_VERSION" {
  description = "local write cache (version) for local-android-flutter image build"
  default     = "type=local,mode=max,dest=${LOCAL_ANDROID_FLUTTER_IMAGE_DOCKER_BUILDX_LOCAL_CACHE_VERSION}"
}

variable "LOCAL_ANDROID_FLUTTER_IMAGE_DOCKER_BUILDX_CACHE_WRITE_LATEST" {
  description = "local write cache (latest) for local-android-flutter image build"
  default     = "type=local,mode=max,dest=${LOCAL_ANDROID_FLUTTER_IMAGE_DOCKER_BUILDX_LOCAL_CACHE_LATEST}"
}

variable "LOCAL_ANDROID_FLUTTER_IMAGE_DOCKER_BUILDX_LOCAL_CACHE_READ_VERSION" {
  description = "local read cache (version)"
  default     = "type=local,src=${LOCAL_ANDROID_FLUTTER_IMAGE_DOCKER_BUILDX_LOCAL_CACHE_VERSION}"
}

variable "LOCAL_ANDROID_FLUTTER_IMAGE_DOCKER_BUILDX_LOCAL_CACHE_READ_LATEST" {
  description = "local read cache (latest)"
  default     = "type=local,src=${LOCAL_ANDROID_FLUTTER_IMAGE_DOCKER_BUILDX_LOCAL_CACHE_LATEST}"
}

variable "ANDROID_NDK_VERSION" {
  default = "27.0.12077973"
}

variable "FLUTTER_VERSION" {
  default = "3.35.6"
}

group "local-android-flutter-ci" {
  targets = [
    "local-android-flutter-version-ci",
    "local-android-flutter-latest-ci"
  ]
}

target "local-android-flutter-version-ci" {
  args = {
    flutter_version     = FLUTTER_VERSION
    android_ndk_version = ANDROID_NDK_VERSION
  }
  contexts = {
    android_apk_emulator_image = "target:local-android-emulator-version-ci"
  }
  context = LOCAL_ANDROID_FLUTTER_DIR
  tags = [
    LOCAL_ANDROID_FLUTTER_VERSION,
  ]
  cache-from = concat(
    USE_REGISTRY_CACHE ? [
      "type=registry,ref=${LOCAL_ANDROID_FLUTTER_IMAGE_REGISTRY_CACHE}",
      "type=registry,ref=${LOCAL_ANDROID_EMULATOR_IMAGE_REGISTRY_CACHE}",
      "type=registry,ref=${LOCAL_DEBIAN_IMAGE_REGISTRY_CACHE}"
    ] : [],
    ENABLE_LOCAL_CACHE ? [
      LOCAL_ANDROID_FLUTTER_IMAGE_DOCKER_BUILDX_LOCAL_CACHE_READ_VERSION
    ] : [],
    [
      "type=inline,ref=${LOCAL_ANDROID_FLUTTER_IMAGE_LATEST}",
      "type=inline,ref=${LOCAL_DEBIAN_IMAGE_LATEST}"
    ]
  )
  cache-to = concat(
    ENABLE_LOCAL_CACHE ? [
      LOCAL_ANDROID_FLUTTER_IMAGE_DOCKER_BUILDX_CACHE_WRITE_VERSION
    ] : []
  )
  platforms = platforms
}

target "local-android-flutter-latest-ci" {
  args = {
    flutter_version     = FLUTTER_VERSION
    android_ndk_version = ANDROID_NDK_VERSION
  }
  contexts = {
    android_apk_emulator_image = "target:local-android-emulator-latest-ci"
  }
  context = LOCAL_ANDROID_FLUTTER_DIR
  tags = [
    LOCAL_ANDROID_FLUTTER_IMAGE_LATEST,
  ]
  cache-from = concat(
    USE_REGISTRY_CACHE ? [
      "type=registry,ref=${LOCAL_ANDROID_FLUTTER_IMAGE_REGISTRY_CACHE}",
      "type=registry,ref=${LOCAL_ANDROID_EMULATOR_IMAGE_REGISTRY_CACHE}",
      "type=registry,ref=${LOCAL_DEBIAN_IMAGE_REGISTRY_CACHE}"
    ] : [],
    ENABLE_LOCAL_CACHE ? [
      LOCAL_ANDROID_FLUTTER_IMAGE_DOCKER_BUILDX_LOCAL_CACHE_READ_LATEST
    ] : [],
    [
      "type=inline,ref=${LOCAL_ANDROID_FLUTTER_IMAGE_LATEST}",
      "type=inline,ref=${LOCAL_ANDROID_EMULATOR_IMAGE_LATEST}",
      "type=inline,ref=${LOCAL_DEBIAN_IMAGE_LATEST}"
    ]
  )
  cache-to = concat(
    USE_REGISTRY_CACHE ? [
      "type=registry,ref=${LOCAL_ANDROID_FLUTTER_IMAGE_REGISTRY_CACHE},mode=max"
    ] : [],
    ENABLE_LOCAL_CACHE ? [
      LOCAL_ANDROID_FLUTTER_IMAGE_DOCKER_BUILDX_CACHE_WRITE_LATEST
    ] : [],
    [
      "type=inline"
    ]
  )
  platforms = platforms
}

target "local-android-flutter" {
  args = {
    flutter_version     = FLUTTER_VERSION
    android_ndk_version = ANDROID_NDK_VERSION
  }
  contexts = {
    android_apk_emulator_image = "target:local-android-emulator"
  }
  context = LOCAL_ANDROID_FLUTTER_DIR
  tags = [
    LOCAL_ANDROID_FLUTTER_IMAGE_LATEST,
    LOCAL_ANDROID_FLUTTER_VERSION,
  ]
  cache-from = concat(
    USE_REGISTRY_CACHE ? [
      "type=registry,ref=${LOCAL_ANDROID_FLUTTER_IMAGE_REGISTRY_CACHE}",
      "type=registry,ref=${LOCAL_ANDROID_EMULATOR_IMAGE_REGISTRY_CACHE}",
      "type=registry,ref=${LOCAL_DEBIAN_IMAGE_REGISTRY_CACHE}"
    ] : [],
    ENABLE_LOCAL_CACHE ? [
      LOCAL_ANDROID_FLUTTER_IMAGE_DOCKER_BUILDX_LOCAL_CACHE_READ_LATEST
    ] : [],
    [
      "type=inline,ref=${LOCAL_ANDROID_FLUTTER_IMAGE_LATEST}",
      "type=inline,ref=${LOCAL_ANDROID_EMULATOR_IMAGE_LATEST}",
      "type=inline,ref=${LOCAL_DEBIAN_IMAGE_LATEST}"
    ]
  )
  cache-to = concat(
    ENABLE_LOCAL_CACHE ? [
      LOCAL_ANDROID_FLUTTER_IMAGE_DOCKER_BUILDX_CACHE_WRITE_LATEST
    ] : []
  )
}
