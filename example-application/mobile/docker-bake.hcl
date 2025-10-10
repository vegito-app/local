variable "LOCAL_EXAMPLE_APPLICATION_MOBILE_DIR" {
  description = "Local directory for the mobile application"
  default     = "${LOCAL_EXAMPLE_APPLICATION_DIR}/mobile"
}

variable "LOCAL_EXAMPLE_APPLICATION_MOBILE_IMAGE_TAG" {
  default = notequal("", VERSION) ? "${VEGITO_LOCAL_PUBLIC_IMAGES_BASE}:application-mobile-${VERSION}" : ""
}

variable "LOCAL_EXAMPLE_APPLICATION_MOBILE_IMAGE_LATEST" {
  default = "${VEGITO_LOCAL_PUBLIC_IMAGES_BASE}:application-mobile-latest"
}

variable "LOCAL_EXAMPLE_APPLICATION_MOBILE_IMAGE_DOCKER_BUILDX_CACHE_WRITE" {
  description = "local write cache for application-mobile image build"
}

variable "LOCAL_EXAMPLE_APPLICATION_MOBILE_IMAGE_DOCKER_BUILDX_LOCAL_CACHE_READ" {
  description = "local read cache for application-mobile image build (cannot be used before first write)"
}

variable "LOCAL_EXAMPLE_APPLICATION_MOBILE_ANDROID_STUDIO_IMAGE" {
  description = "Android Studio image to use for mobile application builds"
  default     = "${VEGITO_LOCAL_PUBLIC_IMAGES_BASE}:android-studio-latest"
}

variable "LOCAL_EXAMPLE_APPLICATION_MOBILE_IMAGE_REGISTRY_CACHE" {
  default = "${VEGITO_LOCAL_PUBLIC_IMAGES_BASE}/cache/local-example-application-mobile"
}

variable "LOCAL_EXAMPLE_APPLICATION_MOBILE_IMAGE_REGISTRY_CACHE_CI" {
  default = "${LOCAL_EXAMPLE_APPLICATION_MOBILE_IMAGE_REGISTRY_CACHE}-ci"
}

variable "LOCAL_EXAMPLE_APPLICATION_MOBILE_APK_BUILDER_IMAGE" {
  description = "Android Studio image to use for mobile application builds"
  default     = "${VEGITO_LOCAL_PUBLIC_IMAGES_BASE}:android-flutter-${VERSION}"
}

variable "LOCAL_EXAMPLE_APPLICATION_MOBILE_APK_BUILDER_IMAGE_LATEST" {
  description = "Android Studio image to use for mobile application builds"
  default     = "${VEGITO_LOCAL_PUBLIC_IMAGES_BASE}:android-flutter-latest"
}

variable "LOCAL_EXAMPLE_APPLICATION_MOBILE_APK_RUNNER_APPIUM_IMAGE" {
  description = "Android Studio image to use for mobile application builds"
  default     = "${VEGITO_LOCAL_PUBLIC_IMAGES_BASE}:android-appium-${VERSION}"
}

variable "LOCAL_EXAMPLE_APPLICATION_MOBILE_APK_RUNNER_APPIUM_IMAGE_LATEST" {
  description = "Android Studio image to use for mobile application builds"
  default     = "${VEGITO_LOCAL_PUBLIC_IMAGES_BASE}:android-appium-latest"
}

variable "LOCAL_EXAMPLE_APPLICATION_MOBILE_ANDROID_RELEASE_KEYSTORE_PATH" {
  description = "Keystore for signing Android releases"
  default     = "${LOCAL_EXAMPLE_APPLICATION_MOBILE_DIR}/android/release-${INFRA_ENV}.keystore"
}

variable "LOCAL_EXAMPLE_APPLICATION_MOBILE_ANDROID_RELEASE_KEYSTORE_BASE64_PATH" {
  description = "Keystore for signing Android releases"
  default     = "${LOCAL_EXAMPLE_APPLICATION_MOBILE_ANDROID_RELEASE_KEYSTORE_PATH}.base64"
}

variable "LOCAL_EXAMPLE_APPLICATION_MOBILE_ANDROID_RELEASE_KEYSTORE_STORE_PASS_BASE64_PATH" {
  description = "Keystore for signing Android releases"
  default     = "${LOCAL_EXAMPLE_APPLICATION_MOBILE_ANDROID_RELEASE_KEYSTORE_PATH}.storepass.base64"
}

target "local-example-application-mobile" {
  args = {
    apk_builder_image = LOCAL_EXAMPLE_APPLICATION_MOBILE_APK_BUILDER_IMAGE_LATEST
    apk_runner_appium_image = LOCAL_EXAMPLE_APPLICATION_MOBILE_APK_RUNNER_APPIUM_IMAGE_LATEST
    environment          = INFRA_ENV
    version = VERSION
  }
  secret = [
    {
      id  = "keystore"
      src = LOCAL_EXAMPLE_APPLICATION_MOBILE_ANDROID_RELEASE_KEYSTORE_BASE64_PATH
    },
    {
      id  = "keystore_store_pass"
      src = LOCAL_EXAMPLE_APPLICATION_MOBILE_ANDROID_RELEASE_KEYSTORE_STORE_PASS_BASE64_PATH
    }
  ]
  context = LOCAL_EXAMPLE_APPLICATION_MOBILE_DIR
  contexts = {
    "android" : LOCAL_ANDROID_DIR
    "approot" : LOCAL_EXAMPLE_APPLICATION_DIR
    "project": "."
  }
  tags = [
    LOCAL_EXAMPLE_APPLICATION_MOBILE_IMAGE_LATEST,
    LOCAL_EXAMPLE_APPLICATION_MOBILE_IMAGE_TAG,
  ]
  cache-from = [
    USE_REGISTRY_CACHE ? "type=registry,ref=${LOCAL_EXAMPLE_APPLICATION_MOBILE_IMAGE_REGISTRY_CACHE}" : "",
    LOCAL_EXAMPLE_APPLICATION_MOBILE_IMAGE_DOCKER_BUILDX_LOCAL_CACHE_READ,
    "type=inline,ref=${LOCAL_EXAMPLE_APPLICATION_MOBILE_IMAGE_LATEST}",
  ]
  cache-to = [
    USE_REGISTRY_CACHE ? "type=registry,ref=${LOCAL_EXAMPLE_APPLICATION_MOBILE_IMAGE_REGISTRY_CACHE},mode=max" : LOCAL_EXAMPLE_APPLICATION_MOBILE_IMAGE_DOCKER_BUILDX_CACHE_WRITE
  ]
  platforms = ["linux/amd64"]
}

target "local-example-application-mobile-ci" {
  args = {
    apk_builder_image = LOCAL_EXAMPLE_APPLICATION_MOBILE_APK_BUILDER_IMAGE
    apk_runner_appium_image = LOCAL_EXAMPLE_APPLICATION_MOBILE_APK_RUNNER_APPIUM_IMAGE
    version = VERSION
  }
  secret = [
    {
      id  = "keystore"
      src = LOCAL_EXAMPLE_APPLICATION_MOBILE_ANDROID_RELEASE_KEYSTORE_BASE64_PATH
    },
    {
      id  = "keystore_store_pass"
      src = LOCAL_EXAMPLE_APPLICATION_MOBILE_ANDROID_RELEASE_KEYSTORE_STORE_PASS_BASE64_PATH
    }
  ]
  context = LOCAL_EXAMPLE_APPLICATION_MOBILE_DIR
  contexts = {
    "android" : LOCAL_ANDROID_DIR
    "approot" : LOCAL_EXAMPLE_APPLICATION_DIR
    "project": "."
  }
  tags = [
    LOCAL_EXAMPLE_APPLICATION_MOBILE_IMAGE_LATEST,
    LOCAL_EXAMPLE_APPLICATION_MOBILE_IMAGE_TAG,
  ]
  cache-from = [
    USE_REGISTRY_CACHE ? "type=registry,ref=${LOCAL_EXAMPLE_APPLICATION_MOBILE_IMAGE_REGISTRY_CACHE_CI}" : "",
    "type=inline,ref=${LOCAL_EXAMPLE_APPLICATION_MOBILE_IMAGE_LATEST}",
    LOCAL_EXAMPLE_APPLICATION_MOBILE_IMAGE_DOCKER_BUILDX_LOCAL_CACHE_READ,
  ]
  cache-to = [
    USE_REGISTRY_CACHE ? "type=registry,ref=${LOCAL_EXAMPLE_APPLICATION_MOBILE_IMAGE_REGISTRY_CACHE_CI},mode=max" : "type=inline"
  ]
  platforms = ["linux/amd64"]
}
