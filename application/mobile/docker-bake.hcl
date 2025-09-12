variable "LOCAL_APPLICATION_MOBILE_IMAGE_VERSION" {
  default = notequal("", VERSION) ? "${VEGITO_LOCAL_PUBLIC_IMAGES_BASE}:application-mobile-${VERSION}" : ""
}

variable "LOCAL_APPLICATION_MOBILE_IMAGE_LATEST" {
  default = "${VEGITO_LOCAL_PUBLIC_IMAGES_BASE}:application-mobile-latest"
}

variable "LOCAL_APPLICATION_MOBILE_APK_BUILDER_IMAGE" {
  description = "Android Studio image to use for mobile application builds"
  default     = "${VEGITO_LOCAL_PUBLIC_IMAGES_BASE}:android-flutter-latest"
}

variable "LOCAL_APPLICATION_MOBILE_APK_RUNNER_APPIUM_IMAGE" {
  description = "Android Studio image to use for mobile application builds"
  default     = "${VEGITO_LOCAL_PUBLIC_IMAGES_BASE}:android-appium-latest"
}

variable "LOCAL_APPLICATION_MOBILE_REGISTRY_CACHE_IMAGE" {
  default = "${VEGITO_LOCAL_PUBLIC_IMAGES_BASE}/cache/local-application-mobile"
}

variable "LOCAL_APPLICATION_MOBILE_IMAGE_REGISTRY_CACHE_CI" {
  default = "${VEGITO_LOCAL_PUBLIC_IMAGES_BASE}/cache/local-application-mobile-ci"
}

variable "LOCAL_APPLICATION_MOBILE_DIR" {
  default = "${LOCAL_APPLICATION_DIR}/mobile"
}

variable "LOCAL_APPLICATION_MOBILE_IMAGE_DOCKER_BUILDX_LOCAL_CACHE" {
  default = "${LOCAL_APPLICATION_MOBILE_DIR}/.containers/android-flutter/docker-buildx-cache"
}

variable "LOCAL_APPLICATION_MOBILE_IMAGE_DOCKER_BUILDX_CACHE_WRITE" {
  description = "local write cache for local-android-flutter image build"
  default = "type=local,mode=max,dest=${LOCAL_APPLICATION_MOBILE_IMAGE_DOCKER_BUILDX_LOCAL_CACHE}"
}

variable "LOCAL_APPLICATION_MOBILE_IMAGE_DOCKER_BUILDX_LOCAL_CACHE_READ" {
  description = "local read cache for local-android-flutter image build (cannot be used before first write)"
  default = "type=local,src=${LOCAL_APPLICATION_MOBILE_IMAGE_DOCKER_BUILDX_LOCAL_CACHE}"
}

target "local-application-mobile" {
  args = {
    apk_builder_image = LOCAL_APPLICATION_MOBILE_APK_BUILDER_IMAGE
    apk_runner_appium_image = LOCAL_APPLICATION_MOBILE_APK_RUNNER_APPIUM_IMAGE
    environment          = INFRA_ENV
  }
  context = LOCAL_APPLICATION_MOBILE_DIR
  contexts = {
    "approot" : LOCAL_APPLICATION_DIR
    "project": "."
  }
  tags = [
    LOCAL_APPLICATION_MOBILE_IMAGE_LATEST,
    LOCAL_APPLICATION_MOBILE_IMAGE_VERSION,
  ]
  cache-from = [
    USE_REGISTRY_CACHE ? "type=registry,ref=${LOCAL_APPLICATION_MOBILE_REGISTRY_CACHE_IMAGE}" : "",
    LOCAL_APPLICATION_MOBILE_IMAGE_DOCKER_BUILDX_LOCAL_CACHE_READ,
    # "type=inline,ref=${LOCAL_APPLICATION_MOBILE_IMAGE_LATEST}",
  ]
  cache-to = [
    USE_REGISTRY_CACHE ? "type=registry,ref=${LOCAL_APPLICATION_MOBILE_REGISTRY_CACHE_IMAGE},mode=max" : LOCAL_APPLICATION_MOBILE_IMAGE_DOCKER_BUILDX_CACHE_WRITE
  ]
  platforms = ["linux/amd64"]
}

target "local-application-mobile-ci" {
  args = {
    apk_builder_image = LOCAL_APPLICATION_MOBILE_APK_BUILDER_IMAGE
    apk_runner_appium_image = LOCAL_APPLICATION_MOBILE_APK_RUNNER_APPIUM_IMAGE
    environment          = INFRA_ENV
  }
  context = LOCAL_APPLICATION_MOBILE_DIR
  contexts = {
    "approot" : LOCAL_APPLICATION_DIR
    "project": "."
  }
  tags = [
    LOCAL_APPLICATION_MOBILE_IMAGE_LATEST,
    LOCAL_APPLICATION_MOBILE_IMAGE_VERSION,
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
