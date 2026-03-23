variable "LOCAL_ANDROID_STUDIO_DIR" {
  default = "android/studio"
}

variable "LOCAL_ANDROID_STUDIO_VERSION" {
  default = notequal("", VERSION) ? "${VEGITO_LOCAL_PUBLIC_IMAGES_BASE}:android-studio-${VERSION}" : ""
}

variable "LOCAL_ANDROID_STUDIO_IMAGE_LATEST" {
  default = "${VEGITO_LOCAL_PUBLIC_IMAGES_BASE}:android-studio-latest"
}

variable "LOCAL_ANDROID_STUDIO_IMAGE_REGISTRY_CACHE" {
  default = "${VEGITO_LOCAL_CACHE_IMAGES_BASE}/android-studio"
}

variable "LOCAL_ANDROID_STUDIO_IMAGE_DOCKER_BUILDX_LOCAL_CACHE" {
  default = "${LOCAL_DOCKER_BUILDX_LOCAL_CACHE_DIR}/android-studio"
}

variable "LOCAL_ANDROID_STUDIO_IMAGE_DOCKER_BUILDX_CACHE_WRITE" {
  description = "local write cache for local-android-studio image build"
  default     = "type=local,mode=max,dest=${LOCAL_ANDROID_STUDIO_IMAGE_DOCKER_BUILDX_LOCAL_CACHE}"
}

variable "LOCAL_ANDROID_STUDIO_IMAGE_DOCKER_BUILDX_LOCAL_CACHE_READ" {
  description = "local read cache for local-android-studio image build (cannot be used before first write)"
  default     = "type=local,src=${LOCAL_ANDROID_STUDIO_IMAGE_DOCKER_BUILDX_LOCAL_CACHE}"
}

variable "ANDROID_STUDIO_VERSION" {
  default = "2025.3.3.4"
}

target "local-android-studio-ci" {
  args = {
    android_studio_version = ANDROID_STUDIO_VERSION
  }
  context = LOCAL_ANDROID_STUDIO_DIR
  contexts = {
    "appium" : "${LOCAL_DIR}/android/appium",
    flutter = "target:local-android-flutter-ci"
  }
  tags = [
    LOCAL_ANDROID_STUDIO_VERSION,
  ]
  cache-from = concat(
    USE_REGISTRY_CACHE ? [
      "type=registry,ref=${LOCAL_ANDROID_STUDIO_IMAGE_REGISTRY_CACHE}",
      "type=registry,ref=${LOCAL_ANDROID_FLUTTER_IMAGE_REGISTRY_CACHE}",
      "type=registry,ref=${LOCAL_ANDROID_EMULATOR_IMAGE_REGISTRY_CACHE}"
    ] : [],
    [
      "type=inline,ref=${LOCAL_ANDROID_STUDIO_IMAGE_LATEST}",
      "type=inline,ref=${LOCAL_ANDROID_FLUTTER_IMAGE_LATEST}",
      "type=inline,ref=${LOCAL_ANDROID_EMULATOR_IMAGE_LATEST}"
    ]
  )
  cache-to  = []
  platforms = platforms
}

target "local-android-studio-latest-ci" {
  args = {
    android_studio_version = ANDROID_STUDIO_VERSION
  }
  context = LOCAL_ANDROID_STUDIO_DIR
  contexts = {
    "appium" : "${LOCAL_DIR}/android/appium",
    flutter = "target:local-android-flutter-ci"
  }
  tags = [
    LOCAL_ANDROID_STUDIO_IMAGE_LATEST,
  ]
  cache-from = concat(
    USE_REGISTRY_CACHE ? [
      "type=registry,ref=${LOCAL_ANDROID_STUDIO_IMAGE_REGISTRY_CACHE}",
      "type=registry,ref=${LOCAL_ANDROID_FLUTTER_IMAGE_REGISTRY_CACHE}",
      "type=registry,ref=${LOCAL_ANDROID_EMULATOR_IMAGE_REGISTRY_CACHE}"
    ] : [],
    [
      "type=inline,ref=${LOCAL_ANDROID_STUDIO_IMAGE_LATEST}",
      "type=inline,ref=${LOCAL_ANDROID_FLUTTER_IMAGE_LATEST}",
      "type=inline,ref=${LOCAL_ANDROID_EMULATOR_IMAGE_LATEST}"
    ]
  )
  cache-to = [
    USE_REGISTRY_CACHE ? "type=registry,ref=${LOCAL_ANDROID_STUDIO_IMAGE_REGISTRY_CACHE},mode=max" : "type=inline"
  ]
  platforms = platforms
}

target "local-android-studio" {
  args = {
    android_studio_version = ANDROID_STUDIO_VERSION
  }
  context = LOCAL_ANDROID_STUDIO_DIR
  contexts = {
    flutter = "target:local-android-flutter"
    "appium" : "${LOCAL_DIR}/android/appium",
  }
  tags = [
    LOCAL_ANDROID_STUDIO_IMAGE_LATEST,
    LOCAL_ANDROID_STUDIO_VERSION,
  ]
  cache-from = concat(
    ENABLE_LOCAL_CACHE ? [
      LOCAL_ANDROID_STUDIO_IMAGE_DOCKER_BUILDX_LOCAL_CACHE_READ
    ] : [],
    USE_REGISTRY_CACHE ? [
      "type=registry,ref=${LOCAL_ANDROID_STUDIO_IMAGE_REGISTRY_CACHE}",
      "type=registry,ref=${LOCAL_ANDROID_FLUTTER_IMAGE_REGISTRY_CACHE}",
      "type=registry,ref=${LOCAL_ANDROID_EMULATOR_IMAGE_REGISTRY_CACHE}"
    ] : [],
    [
      "type=inline,ref=${LOCAL_ANDROID_STUDIO_IMAGE_LATEST}",
      "type=inline,ref=${LOCAL_ANDROID_FLUTTER_IMAGE_LATEST}",
      "type=inline,ref=${LOCAL_ANDROID_EMULATOR_IMAGE_LATEST}"
    ]
  )
  cache-to = concat(
    ENABLE_LOCAL_CACHE ? [
      LOCAL_ANDROID_STUDIO_IMAGE_DOCKER_BUILDX_CACHE_WRITE
    ] : []
  )
}
