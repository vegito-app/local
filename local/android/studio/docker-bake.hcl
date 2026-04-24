variable "LOCAL_ANDROID_STUDIO_DIR" {
  default = "android/studio"
}

variable "LOCAL_ANDROID_STUDIO_VERSION" {
  default = "${VEGITO_LOCAL_PUBLIC_IMAGES_BASE}:android-studio-${VERSION}"
}

variable "LOCAL_ANDROID_STUDIO_IMAGE_LATEST" {
  default = "${VEGITO_LOCAL_PUBLIC_IMAGES_BASE}:android-studio-latest"
}

variable "LOCAL_ANDROID_STUDIO_IMAGE_REGISTRY_CACHE" {
  default = "${VEGITO_LOCAL_CACHE_IMAGES_BASE}/android-studio"
}

variable "LOCAL_ANDROID_STUDIO_IMAGE_DOCKER_BUILDX_LOCAL_CACHE_VERSION" {
  default = "${LOCAL_DOCKER_BUILDX_LOCAL_CACHE_DIR}/android-studio-version"
}

variable "LOCAL_ANDROID_STUDIO_IMAGE_DOCKER_BUILDX_LOCAL_CACHE_LATEST" {
  default = "${LOCAL_DOCKER_BUILDX_LOCAL_CACHE_DIR}/android-studio-latest"
}

variable "LOCAL_ANDROID_STUDIO_IMAGE_DOCKER_BUILDX_CACHE_WRITE_VERSION" {
  description = "local write cache for local-android-studio image build version"
  default     = "type=local,mode=max,dest=${LOCAL_ANDROID_STUDIO_IMAGE_DOCKER_BUILDX_LOCAL_CACHE_VERSION}"
}

variable "LOCAL_ANDROID_STUDIO_IMAGE_DOCKER_BUILDX_CACHE_WRITE_LATEST" {
  description = "local write cache for local-android-studio image build latest"
  default     = "type=local,mode=max,dest=${LOCAL_ANDROID_STUDIO_IMAGE_DOCKER_BUILDX_LOCAL_CACHE_LATEST}"
}

variable "LOCAL_ANDROID_STUDIO_IMAGE_DOCKER_BUILDX_LOCAL_CACHE_READ_VERSION" {
  description = "local read cache for local-android-studio image build version (cannot be used before first write)"
  default     = "type=local,src=${LOCAL_ANDROID_STUDIO_IMAGE_DOCKER_BUILDX_LOCAL_CACHE_VERSION}"
}

variable "LOCAL_ANDROID_STUDIO_IMAGE_DOCKER_BUILDX_LOCAL_CACHE_READ_LATEST" {
  description = "local read cache for local-android-studio image build latest (cannot be used before first write)"
  default     = "type=local,src=${LOCAL_ANDROID_STUDIO_IMAGE_DOCKER_BUILDX_LOCAL_CACHE_LATEST}"
}

variable "ANDROID_STUDIO_VERSION" {
  default = "2025.3.4.6/android-studio-panda4"
}

group "local-android-studio-ci" {
  description = "Build and push Android Studio images"
  targets = [
    "local-android-studio-version-ci",
    "local-android-studio-latest-ci",
  ]
}

target "local-android-studio-version-ci" {
  args = {
    android_studio_version = ANDROID_STUDIO_VERSION
  }
  context = LOCAL_ANDROID_STUDIO_DIR
  contexts = {
    "appium" : "${LOCAL_DIR}/android/appium",
    flutter = "target:local-android-flutter-version-ci"
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
    ENABLE_LOCAL_CACHE ? [
      LOCAL_ANDROID_STUDIO_IMAGE_DOCKER_BUILDX_LOCAL_CACHE_READ_VERSION
    ] : [],
    [
      "type=inline,ref=${LOCAL_ANDROID_STUDIO_IMAGE_LATEST}",
      "type=inline,ref=${LOCAL_ANDROID_FLUTTER_IMAGE_LATEST}",
      "type=inline,ref=${LOCAL_ANDROID_EMULATOR_IMAGE_LATEST}"
    ]
  )
  cache-to = concat(
    ENABLE_LOCAL_CACHE ? [
      LOCAL_ANDROID_STUDIO_IMAGE_DOCKER_BUILDX_CACHE_WRITE_VERSION
    ] : []
  )
  platforms = platforms
}

target "local-android-studio-latest-ci" {
  args = {
    android_studio_version = ANDROID_STUDIO_VERSION
  }
  context = LOCAL_ANDROID_STUDIO_DIR
  contexts = {
    "appium" : "${LOCAL_DIR}/android/appium",
    flutter = "target:local-android-flutter-latest-ci"
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
    ENABLE_LOCAL_CACHE ? [
      LOCAL_ANDROID_STUDIO_IMAGE_DOCKER_BUILDX_LOCAL_CACHE_READ_LATEST
    ] : [],
    [
      "type=inline,ref=${LOCAL_ANDROID_STUDIO_IMAGE_LATEST}",
      "type=inline,ref=${LOCAL_ANDROID_FLUTTER_IMAGE_LATEST}",
      "type=inline,ref=${LOCAL_ANDROID_EMULATOR_IMAGE_LATEST}"
    ]
  )
  cache-to = concat(
    USE_REGISTRY_CACHE ? [
      "type=registry,ref=${LOCAL_ANDROID_STUDIO_IMAGE_REGISTRY_CACHE},mode=max"
    ] : [],
    ENABLE_LOCAL_CACHE ? [
      LOCAL_ANDROID_STUDIO_IMAGE_DOCKER_BUILDX_CACHE_WRITE_LATEST
    ] : [],
    [
      "type=inline"
    ]
  )
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
    USE_REGISTRY_CACHE ? [
      "type=registry,ref=${LOCAL_ANDROID_STUDIO_IMAGE_REGISTRY_CACHE}",
      "type=registry,ref=${LOCAL_ANDROID_FLUTTER_IMAGE_REGISTRY_CACHE}",
      "type=registry,ref=${LOCAL_ANDROID_EMULATOR_IMAGE_REGISTRY_CACHE}"
    ] : [],
    ENABLE_LOCAL_CACHE ? [
      LOCAL_ANDROID_STUDIO_IMAGE_DOCKER_BUILDX_LOCAL_CACHE_READ_LATEST
    ] : [],
    [
      "type=inline,ref=${LOCAL_ANDROID_STUDIO_IMAGE_LATEST}",
      "type=inline,ref=${LOCAL_ANDROID_FLUTTER_IMAGE_LATEST}",
      "type=inline,ref=${LOCAL_ANDROID_EMULATOR_IMAGE_LATEST}"
    ]
  )
  cache-to = concat(
    ENABLE_LOCAL_CACHE ? [
      LOCAL_ANDROID_STUDIO_IMAGE_DOCKER_BUILDX_CACHE_WRITE_LATEST
    ] : []
  )
}
