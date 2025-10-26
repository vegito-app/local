variable "EXAMPLE_APPLICATION_MOBILE_DIR" {
  description = "Local directory for the mobile application"
  default     = "${EXAMPLE_APPLICATION_DIR}/mobile"
}

variable "EXAMPLE_APPLICATION_MOBILE_IMAGE_TAG" {
  default = notequal("", VERSION) ? "${VEGITO_LOCAL_PUBLIC_IMAGES_BASE}:example-application-mobile-${VERSION}" : ""
}

variable "EXAMPLE_APPLICATION_MOBILE_IMAGE_LATEST" {
  default = "${VEGITO_LOCAL_PUBLIC_IMAGES_BASE}:example-application-mobile-latest"
}

variable "EXAMPLE_APPLICATION_MOBILE_IMAGE_DOCKER_BUILDX_CACHE_WRITE" {
  description = "local write cache for application-mobile image build"
}

variable "EXAMPLE_APPLICATION_MOBILE_IMAGE_DOCKER_BUILDX_LOCAL_CACHE_READ" {
  description = "local read cache for application-mobile image build (cannot be used before first write)"
}

variable "EXAMPLE_APPLICATION_MOBILE_ANDROID_STUDIO_IMAGE" {
  description = "Android Studio image to use for mobile application builds"
  default     = "${VEGITO_LOCAL_PUBLIC_IMAGES_BASE}:android-studio-latest"
}

variable "EXAMPLE_APPLICATION_MOBILE_IMAGE_REGISTRY_CACHE" {
  default = "${VEGITO_LOCAL_PUBLIC_IMAGES_BASE}/cache/example-application-mobile"
}

variable "EXAMPLE_APPLICATION_MOBILE_IMAGE_REGISTRY_CACHE_CI" {
  default = "${EXAMPLE_APPLICATION_MOBILE_IMAGE_REGISTRY_CACHE}-ci"
}

variable "EXAMPLE_APPLICATION_MOBILE_APK_BUILDER_IMAGE" {
  description = "Android Studio image to use for mobile application builds"
  default     = "${VEGITO_LOCAL_PUBLIC_IMAGES_BASE}:android-flutter-${VERSION}"
}

variable "EXAMPLE_APPLICATION_MOBILE_APK_BUILDER_IMAGE_LATEST" {
  description = "Android Studio image to use for mobile application builds"
  default     = "${VEGITO_LOCAL_PUBLIC_IMAGES_BASE}:android-flutter-latest"
}

variable "EXAMPLE_APPLICATION_MOBILE_APK_RUNNER_APPIUM_IMAGE" {
  description = "Android Studio image to use for mobile application builds"
  default     = "${VEGITO_LOCAL_PUBLIC_IMAGES_BASE}:android-appium-${VERSION}"
}

variable "EXAMPLE_APPLICATION_MOBILE_APK_RUNNER_APPIUM_IMAGE_LATEST" {
  description = "Android Studio image to use for mobile application builds"
  default     = "${VEGITO_LOCAL_PUBLIC_IMAGES_BASE}:android-appium-latest"
}

variable "EXAMPLE_APPLICATION_MOBILE_ANDROID_RELEASE_KEYSTORE_PATH" {
  description = "Keystore for signing Android releases"
  default     = "${EXAMPLE_APPLICATION_MOBILE_DIR}/android/release-${INFRA_ENV}.keystore"
}

variable "EXAMPLE_APPLICATION_MOBILE_ANDROID_RELEASE_KEYSTORE_BASE64_PATH" {
  description = "Keystore for signing Android releases"
  default     = "${EXAMPLE_APPLICATION_MOBILE_ANDROID_RELEASE_KEYSTORE_PATH}.base64"
}

variable "EXAMPLE_APPLICATION_MOBILE_ANDROID_RELEASE_KEYSTORE_STORE_PASS_BASE64_PATH" {
  description = "Keystore for signing Android releases"
  default     = "${EXAMPLE_APPLICATION_MOBILE_ANDROID_RELEASE_KEYSTORE_PATH}.storepass.base64"
}

target "example-application-mobile" {
  args = {
    # apk_builder_image       = EXAMPLE_APPLICATION_MOBILE_APK_BUILDER_IMAGE_LATEST
    apk_runner_appium_image = LOCAL_ANDROID_APPIUM_IMAGE_VERSION
    # environment             = INFRA_ENV
    version = VERSION
  }
  secret = [
    {
      id  = "keystore"
      src = EXAMPLE_APPLICATION_MOBILE_ANDROID_RELEASE_KEYSTORE_BASE64_PATH
    },
    {
      id  = "keystore_store_pass"
      src = EXAMPLE_APPLICATION_MOBILE_ANDROID_RELEASE_KEYSTORE_STORE_PASS_BASE64_PATH
    }
  ]
  context = EXAMPLE_APPLICATION_MOBILE_DIR
  contexts = {
    "android" : LOCAL_ANDROID_DIR
    "approot" : EXAMPLE_APPLICATION_DIR
    "project" : "."
  }
  tags = [
    EXAMPLE_APPLICATION_MOBILE_IMAGE_LATEST,
    EXAMPLE_APPLICATION_MOBILE_IMAGE_TAG,
  ]
  cache-from = [
    USE_REGISTRY_CACHE ? "type=registry,ref=${EXAMPLE_APPLICATION_MOBILE_IMAGE_REGISTRY_CACHE}" : "",
    EXAMPLE_APPLICATION_MOBILE_IMAGE_DOCKER_BUILDX_LOCAL_CACHE_READ,
    "type=inline,ref=${EXAMPLE_APPLICATION_MOBILE_IMAGE_LATEST}",
  ]
  cache-to = [
    USE_REGISTRY_CACHE ? "type=registry,ref=${EXAMPLE_APPLICATION_MOBILE_IMAGE_REGISTRY_CACHE},mode=max" : EXAMPLE_APPLICATION_MOBILE_IMAGE_DOCKER_BUILDX_CACHE_WRITE
  ]
  platforms = ["linux/amd64"]
}

target "example-application-mobile-ci" {
  args = {
    apk_runner_appium_image = LOCAL_ANDROID_APPIUM_IMAGE_VERSION
    version                 = VERSION
  }
  secret = [
    {
      id  = "keystore"
      src = EXAMPLE_APPLICATION_MOBILE_ANDROID_RELEASE_KEYSTORE_BASE64_PATH
    },
    {
      id  = "keystore_store_pass"
      src = EXAMPLE_APPLICATION_MOBILE_ANDROID_RELEASE_KEYSTORE_STORE_PASS_BASE64_PATH
    }
  ]
  context = EXAMPLE_APPLICATION_MOBILE_DIR
  contexts = {
    "android" : LOCAL_ANDROID_DIR
    "approot" : EXAMPLE_APPLICATION_DIR
    "project" : "."
  }
  tags = [
    EXAMPLE_APPLICATION_MOBILE_IMAGE_LATEST,
    EXAMPLE_APPLICATION_MOBILE_IMAGE_TAG,
  ]
  cache-from = [
    USE_REGISTRY_CACHE ? "type=registry,ref=${EXAMPLE_APPLICATION_MOBILE_IMAGE_REGISTRY_CACHE_CI}" : "",
    "type=inline,ref=${EXAMPLE_APPLICATION_MOBILE_IMAGE_LATEST}",
    EXAMPLE_APPLICATION_MOBILE_IMAGE_DOCKER_BUILDX_LOCAL_CACHE_READ,
  ]
  cache-to = [
    USE_REGISTRY_CACHE ? "type=registry,ref=${EXAMPLE_APPLICATION_MOBILE_IMAGE_REGISTRY_CACHE_CI},mode=max" : "type=inline"
  ]
  platforms = ["linux/amd64"]
}
