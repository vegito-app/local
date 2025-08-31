variable "APPLICATION_MOBILE_IMAGE_TAG" {
  default = notequal("", VERSION) ? "${VEGITO_LOCAL_PUBLIC_IMAGES_BASE}:application-mobile-${VERSION}" : ""
}

variable "APPLICATION_MOBILE_IMAGE_LATEST" {
  default = "${VEGITO_LOCAL_PUBLIC_IMAGES_BASE}:application-mobile-latest"
}

variable "APPLICATION_MOBILE_IMAGE_DOCKER_BUILDX_CACHE_WRITE" {
  description = "local write cache for application-mobile image build"
}

variable "APPLICATION_MOBILE_IMAGE_DOCKER_BUILDX_LOCAL_CACHE_READ" {
  description = "local read cache for application-mobile image build (cannot be used before first write)"
}

variable "APPLICATION_MOBILE_APK_BUILDER_IMAGE" {
  description = "Android Studio image to use for mobile application builds"
  default     = "${VEGITO_LOCAL_PUBLIC_IMAGES_BASE}:android-flutter-latest"
}

variable "APPLICATION_MOBILE_APK_RUNNER_APPIUM_IMAGE" {
  description = "Android Studio image to use for mobile application builds"
  default     = "${VEGITO_LOCAL_PUBLIC_IMAGES_BASE}:android-appium-latest"
}

variable "APPLICATION_MOBILE_REGISTRY_CACHE_IMAGE" {
  default = "${VEGITO_LOCAL_PUBLIC_IMAGES_BASE}/cache/local-application-mobile"
}

target "local-application-mobile" {
  args = {
    apk_builder_image = APPLICATION_MOBILE_APK_BUILDER_IMAGE
    apk_runner_appium_image = APPLICATION_MOBILE_APK_RUNNER_APPIUM_IMAGE
  }
  context = "${APPLICATION_DIR}/mobile"
  contexts = {
    "approot" : APPLICATION_DIR
    "project": "."
  }
  tags = [
    APPLICATION_MOBILE_IMAGE_LATEST,
    APPLICATION_MOBILE_IMAGE_TAG,
  ]
  cache-from = [
    USE_REGISTRY_CACHE ? "type=registry,ref=${APPLICATION_MOBILE_REGISTRY_CACHE_IMAGE}" : "",
    APPLICATION_MOBILE_IMAGE_DOCKER_BUILDX_LOCAL_CACHE_READ,
    "type=inline, ref=${APPLICATION_MOBILE_IMAGE_LATEST}",
  ]
  cache-to = [
    USE_REGISTRY_CACHE ? "type=registry,ref=${APPLICATION_MOBILE_REGISTRY_CACHE_IMAGE},mode=max" : APPLICATION_MOBILE_IMAGE_DOCKER_BUILDX_CACHE_WRITE
  ]
  platforms = ["linux/amd64"]
}

target "local-application-mobile-ci" {
  args = {
    apk_builder_image = APPLICATION_MOBILE_APK_BUILDER_IMAGE
    apk_runner_appium_image = APPLICATION_MOBILE_APK_RUNNER_APPIUM_IMAGE
  }
  context = "${APPLICATION_DIR}/mobile"
  contexts = {
    "approot" : APPLICATION_DIR
  }
  tags = [
    APPLICATION_MOBILE_IMAGE_LATEST,
    APPLICATION_MOBILE_IMAGE_TAG,
  ]
  cache-from = [
    USE_REGISTRY_CACHE ? "type=registry,ref=${APPLICATION_MOBILE_REGISTRY_CACHE_IMAGE}" : "",
    "type=inline, ref=${APPLICATION_MOBILE_IMAGE_LATEST}",
    APPLICATION_MOBILE_IMAGE_DOCKER_BUILDX_LOCAL_CACHE_READ,
  ]
  cache-to = [
    USE_REGISTRY_CACHE ? "type=registry,ref=${APPLICATION_MOBILE_REGISTRY_CACHE_IMAGE},mode=max" : "type=inline"
  ]
  platforms = ["linux/amd64"]
}
