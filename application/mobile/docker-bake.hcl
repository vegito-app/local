variable "LOCAL_APPLICATION_MOBILE_IMAGE_TAG" {
  default = notequal("", VERSION) ? "${VEGITO_LOCAL_PUBLIC_IMAGES_BASE}:application-mobile-${VERSION}" : ""
}

variable "LOCAL_APPLICATION_MOBILE_IMAGE_LATEST" {
  default = "${VEGITO_LOCAL_PUBLIC_IMAGES_BASE}:application-mobile-latest"
}

variable "LOCAL_APPLICATION_MOBILE_IMAGE_DOCKER_BUILDX_CACHE_WRITE" {
  description = "local write cache for application-mobile image build"
}

variable "LOCAL_APPLICATION_MOBILE_IMAGE_DOCKER_BUILDX_LOCAL_CACHE_READ" {
  description = "local read cache for application-mobile image build (cannot be used before first write)"
}

variable "LOCAL_APPLICATION_MOBILE_ANDROID_STUDIO_IMAGE" {
  description = "Android Studio image to use for mobile application builds"
  default     = "${VEGITO_LOCAL_PUBLIC_IMAGES_BASE}:android-studio-latest"
}

variable "LOCAL_APPLICATION_MOBILE_IMAGE_REGISTRY_CACHE" {
  default = "${VEGITO_LOCAL_PUBLIC_IMAGES_BASE}/cache/local-application-mobile"
}

variable "LOCAL_APPLICATION_MOBILE_IMAGE_REGISTRY_CACHE_CI" {
  default = "${VEGITO_LOCAL_PUBLIC_IMAGES_BASE}/cache/local-application-mobile-ci"
}

variable "LOCAL_APPLICATION_MOBILE_APK_BUILDER_IMAGE" {
  description = "Android Studio image to use for mobile application builds"
  default     = "${VEGITO_LOCAL_PUBLIC_IMAGES_BASE}:android-flutter-latest"
}
variable "LOCAL_APPLICATION_MOBILE_APK_RUNNER_APPIUM_IMAGE" {
  description = "Android Studio image to use for mobile application builds"
  default     = "${VEGITO_LOCAL_PUBLIC_IMAGES_BASE}:android-appium-latest"
}
target "local-application-mobile" {
  args = {
    apk_builder_image = LOCAL_APPLICATION_MOBILE_APK_BUILDER_IMAGE
    apk_runner_appium_image = LOCAL_APPLICATION_MOBILE_APK_RUNNER_APPIUM_IMAGE
    environment          = INFRA_ENV
  }
  context = "${LOCAL_APPLICATION_DIR}/mobile"
  contexts = {
    "approot" : LOCAL_APPLICATION_DIR
    "project": "."
  }
  tags = [
    LOCAL_APPLICATION_MOBILE_IMAGE_LATEST,
    LOCAL_APPLICATION_MOBILE_IMAGE_TAG,
  ]
  cache-from = [
    USE_REGISTRY_CACHE ? "type=registry,ref=${LOCAL_APPLICATION_MOBILE_IMAGE_REGISTRY_CACHE}" : "",
    LOCAL_APPLICATION_MOBILE_IMAGE_DOCKER_BUILDX_LOCAL_CACHE_READ,
    "type=inline,ref=${LOCAL_APPLICATION_MOBILE_IMAGE_LATEST}",
  ]
  cache-to = [
    USE_REGISTRY_CACHE ? "type=registry,ref=${LOCAL_APPLICATION_MOBILE_IMAGE_REGISTRY_CACHE},mode=max" : LOCAL_APPLICATION_MOBILE_IMAGE_DOCKER_BUILDX_CACHE_WRITE
  ]
  platforms = ["linux/amd64"]
}

target "local-application-mobile-ci" {
  args = {
    apk_builder_image = LOCAL_APPLICATION_MOBILE_APK_BUILDER_IMAGE
    apk_runner_appium_image = LOCAL_APPLICATION_MOBILE_APK_RUNNER_APPIUM_IMAGE
  }
  context = "${LOCAL_APPLICATION_DIR}/mobile"
  contexts = {
    "approot" : LOCAL_APPLICATION_DIR
  }
  tags = [
    LOCAL_APPLICATION_MOBILE_IMAGE_LATEST,
    LOCAL_APPLICATION_MOBILE_IMAGE_TAG,
  ]
  cache-from = [
    USE_REGISTRY_CACHE ? "type=registry,ref=${LOCAL_APPLICATION_MOBILE_IMAGE_REGISTRY_CACHE_CI}" : "",
    "type=inline,ref=${LOCAL_APPLICATION_MOBILE_IMAGE_LATEST}",
    LOCAL_APPLICATION_MOBILE_IMAGE_DOCKER_BUILDX_LOCAL_CACHE_READ,
  ]
  cache-to = [
    USE_REGISTRY_CACHE ? "type=registry,ref=${LOCAL_APPLICATION_MOBILE_IMAGE_REGISTRY_CACHE_CI},mode=max" : "type=inline"
  ]
  platforms = ["linux/amd64"]
}
