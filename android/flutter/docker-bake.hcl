variable "LOCAL_ANDROID_FLUTTER_VERSION" {
  default = notequal("", VERSION) ? "${VEGITO_LOCAL_PUBLIC_IMAGES_BASE}:android-flutter-${VERSION}" : ""
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

variable "LOCAL_ANDROID_FLUTTER_IMAGE_DOCKER_BUILDX_LOCAL_CACHE" {
  default = "${LOCAL_DOCKER_BUILDX_LOCAL_CACHE_DIR}/android-flutter"
}

variable "LOCAL_ANDROID_FLUTTER_IMAGE_DOCKER_BUILDX_CACHE_WRITE" {
  description = "local write cache for local-android-flutter image build"
  default     = "type=local,mode=max,dest=${LOCAL_ANDROID_FLUTTER_IMAGE_DOCKER_BUILDX_LOCAL_CACHE}"
}

variable "LOCAL_ANDROID_FLUTTER_IMAGE_DOCKER_BUILDX_LOCAL_CACHE_READ" {
  description = "local read cache for local-android-flutter image build (cannot be used before first write)"
  default     = "type=local,src=${LOCAL_ANDROID_FLUTTER_IMAGE_DOCKER_BUILDX_LOCAL_CACHE}"
}

variable "ANDROID_NDK_VERSION" {
  default = "27.0.12077973"
}

variable "FLUTTER_VERSION" {
  default = "3.35.6"
}

target "local-android-flutter-ci" {
  args = {
    flutter_version     = FLUTTER_VERSION
    android_ndk_version = ANDROID_NDK_VERSION
  }
  contexts = {
    android_apk_emulator_image = "target:local-android-emulator-ci"
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
    [
      "type=inline,ref=${LOCAL_ANDROID_FLUTTER_IMAGE_LATEST}",
      "type=inline,ref=${LOCAL_DEBIAN_IMAGE_LATEST}"
    ]
  )
  cache-to  = []
  platforms = platforms
}

target "local-android-flutter-latest-ci" {
  args = {
    flutter_version     = FLUTTER_VERSION
    android_ndk_version = ANDROID_NDK_VERSION
  }
  contexts = {
    android_apk_emulator_image = "target:local-android-emulator-ci"
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
    [
      "type=inline,ref=${LOCAL_ANDROID_FLUTTER_IMAGE_LATEST}",
      "type=inline,ref=${LOCAL_ANDROID_EMULATOR_IMAGE_LATEST}",
      "type=inline,ref=${LOCAL_DEBIAN_IMAGE_LATEST}"
    ]
  )
  cache-to = [
    USE_REGISTRY_CACHE ? "type=registry,ref=${LOCAL_ANDROID_FLUTTER_IMAGE_REGISTRY_CACHE},mode=max" : "type=inline"
  ]
  platforms = platforms
}

target "local-android-flutter" {
  args = {
    flutter_version     = FLUTTER_VERSION
    android_ndk_version = ANDROID_NDK_VERSION
  }
  contexts = {
    android_apk_emulator_image = "target:local-android-emulator-ci"
  }
  context = LOCAL_ANDROID_FLUTTER_DIR
  tags = [
    LOCAL_ANDROID_FLUTTER_IMAGE_LATEST,
    LOCAL_ANDROID_FLUTTER_VERSION,
  ]
  cache-from = concat(
    ENABLE_LOCAL_CACHE ? [
      LOCAL_ANDROID_FLUTTER_IMAGE_DOCKER_BUILDX_LOCAL_CACHE_READ
    ] : [],
    USE_REGISTRY_CACHE ? [
      "type=registry,ref=${LOCAL_ANDROID_FLUTTER_IMAGE_REGISTRY_CACHE}",
      "type=registry,ref=${LOCAL_ANDROID_EMULATOR_IMAGE_REGISTRY_CACHE}",
      "type=registry,ref=${LOCAL_DEBIAN_IMAGE_REGISTRY_CACHE}"
    ] : [],
    [
      "type=inline,ref=${LOCAL_ANDROID_FLUTTER_IMAGE_LATEST}",
      "type=inline,ref=${LOCAL_ANDROID_EMULATOR_IMAGE_LATEST}",
      "type=inline,ref=${LOCAL_DEBIAN_IMAGE_LATEST}"
    ]
  )
  cache-to = concat(
    ENABLE_LOCAL_CACHE ? [
      LOCAL_ANDROID_FLUTTER_IMAGE_DOCKER_BUILDX_CACHE_WRITE
    ] : []
  )
}
