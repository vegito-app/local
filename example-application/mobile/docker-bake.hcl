variable "VEGITO_EXAMPLE_APPLICATION_MOBILE_DIR" {
  description = "Local directory for the mobile application"
  default     = "${VEGITO_EXAMPLE_APPLICATION_DIR}/mobile"
}

variable "VEGITO_EXAMPLE_APPLICATION_MOBILE_IMAGE_TAG" {
  default = notequal("", VERSION) ? "${VEGITO_LOCAL_PUBLIC_IMAGES_BASE}:example-application-mobile-${VERSION}" : ""
}

variable "VEGITO_EXAMPLE_APPLICATION_MOBILE_IMAGE_LATEST" {
  default = "${VEGITO_LOCAL_PUBLIC_IMAGES_BASE}:example-application-mobile-latest"
}

variable "VEGITO_EXAMPLE_APPLICATION_MOBILE_IMAGE_DOCKER_BUILDX_LOCAL_CACHE" {
  default = "${LOCAL_DOCKER_BUILDX_LOCAL_CACHE_DIR}/example-application-mobile"
}

variable "VEGITO_EXAMPLE_APPLICATION_MOBILE_IMAGE_DOCKER_BUILDX_CACHE_WRITE" {
  description = "local write cache for clarinet image build"
  default     = "type=local,mode=max,dest=${VEGITO_EXAMPLE_APPLICATION_MOBILE_IMAGE_DOCKER_BUILDX_LOCAL_CACHE}"
}

variable "VEGITO_EXAMPLE_APPLICATION_MOBILE_IMAGE_DOCKER_BUILDX_LOCAL_CACHE_READ" {
  description = "local read cache for clarinet image build (cannot be used before first write)"
  default     = "type=local,src=${VEGITO_EXAMPLE_APPLICATION_MOBILE_IMAGE_DOCKER_BUILDX_LOCAL_CACHE}"
}

variable "VEGITO_EXAMPLE_APPLICATION_MOBILE_ANDROID_STUDIO_IMAGE" {
  description = "Android Studio image to use for mobile application builds"
  default     = "${VEGITO_LOCAL_PUBLIC_IMAGES_BASE}:android-studio-latest"
}

variable "VEGITO_EXAMPLE_APPLICATION_MOBILE_IMAGE_REGISTRY_CACHE" {
  default = "${VEGITO_LOCAL_PUBLIC_IMAGES_BASE}/cache/example-application-mobile"
}

variable "VEGITO_EXAMPLE_APPLICATION_MOBILE_IMAGE_REGISTRY_CACHE_CI" {
  default = "${VEGITO_EXAMPLE_APPLICATION_MOBILE_IMAGE_REGISTRY_CACHE}-ci"
}

variable "VEGITO_EXAMPLE_APPLICATION_MOBILE_APK_BUILDER_IMAGE" {
  description = "Android Studio image to use for mobile application builds"
  default     = "${VEGITO_LOCAL_PUBLIC_IMAGES_BASE}:android-flutter-${LOCAL_VERSION}"
}

variable "VEGITO_EXAMPLE_APPLICATION_MOBILE_APK_BUILDER_IMAGE_LATEST" {
  description = "Android Studio image to use for mobile application builds"
  default     = "${VEGITO_LOCAL_PUBLIC_IMAGES_BASE}:android-flutter-latest"
}

variable "VEGITO_EXAMPLE_APPLICATION_MOBILE_APK_RUNNER_APPIUM_IMAGE" {
  description = "Android Studio image to use for mobile application builds"
  default     = "${VEGITO_LOCAL_PUBLIC_IMAGES_BASE}:android-appium-${LOCAL_VERSION}"
}

variable "VEGITO_EXAMPLE_APPLICATION_MOBILE_APK_RUNNER_APPIUM_IMAGE_LATEST" {
  description = "Android Studio image to use for mobile application builds"
  default     = "${VEGITO_LOCAL_PUBLIC_IMAGES_BASE}:android-appium-latest"
}

variable "VEGITO_EXAMPLE_APPLICATION_MOBILE_ANDROID_RELEASE_KEYSTORE_PATH" {
  description = "Keystore for signing Android releases"
  default     = "${VEGITO_EXAMPLE_APPLICATION_MOBILE_DIR}/android/release-${INFRA_ENV}.keystore"
}

variable "VEGITO_EXAMPLE_APPLICATION_MOBILE_ANDROID_RELEASE_KEYSTORE_BASE64_PATH" {
  description = "Keystore for signing Android releases"
  default     = "${VEGITO_EXAMPLE_APPLICATION_MOBILE_ANDROID_RELEASE_KEYSTORE_PATH}.base64"
}

variable "VEGITO_EXAMPLE_APPLICATION_MOBILE_ANDROID_RELEASE_KEYSTORE_STORE_PASS_BASE64_PATH" {
  description = "Keystore for signing Android releases"
  default     = "${VEGITO_EXAMPLE_APPLICATION_MOBILE_ANDROID_RELEASE_KEYSTORE_PATH}.storepass.base64"
}

target "example-application-mobile" {
  args = {
    apk_builder_image       = VEGITO_EXAMPLE_APPLICATION_MOBILE_APK_BUILDER_IMAGE
    apk_runner_appium_image = VEGITO_EXAMPLE_APPLICATION_MOBILE_APK_RUNNER_APPIUM_IMAGE
    version                 = VERSION
  }
  secret = [
    {
      id  = "keystore"
      src = VEGITO_EXAMPLE_APPLICATION_MOBILE_ANDROID_RELEASE_KEYSTORE_BASE64_PATH
    },
    {
      id  = "keystore_store_pass"
      src = VEGITO_EXAMPLE_APPLICATION_MOBILE_ANDROID_RELEASE_KEYSTORE_STORE_PASS_BASE64_PATH
    }
  ]
  context = VEGITO_EXAMPLE_APPLICATION_MOBILE_DIR
  contexts = {
    "android" : LOCAL_ANDROID_DIR
    "approot" : VEGITO_EXAMPLE_APPLICATION_DIR
  }
  tags = [
    VEGITO_EXAMPLE_APPLICATION_MOBILE_IMAGE_LATEST,
    VEGITO_EXAMPLE_APPLICATION_MOBILE_IMAGE_TAG,
  ]
  cache-from = [
    USE_REGISTRY_CACHE ? "type=registry,ref=${VEGITO_EXAMPLE_APPLICATION_MOBILE_IMAGE_REGISTRY_CACHE}" : "",
    VEGITO_EXAMPLE_APPLICATION_MOBILE_IMAGE_DOCKER_BUILDX_LOCAL_CACHE_READ,
    "type=inline,ref=${VEGITO_EXAMPLE_APPLICATION_MOBILE_IMAGE_LATEST}",
  ]
  cache-to = [
    USE_REGISTRY_CACHE ? "type=registry,ref=${VEGITO_EXAMPLE_APPLICATION_MOBILE_IMAGE_REGISTRY_CACHE},mode=max" : VEGITO_EXAMPLE_APPLICATION_MOBILE_IMAGE_DOCKER_BUILDX_CACHE_WRITE
  ]
}

target "example-application-mobile-ci" {
  args = {
    apk_builder_image       = VEGITO_EXAMPLE_APPLICATION_MOBILE_APK_BUILDER_IMAGE
    apk_runner_appium_image = VEGITO_EXAMPLE_APPLICATION_MOBILE_APK_RUNNER_APPIUM_IMAGE
    version                 = VERSION
  }
  secret = [
    {
      id  = "keystore"
      src = VEGITO_EXAMPLE_APPLICATION_MOBILE_ANDROID_RELEASE_KEYSTORE_BASE64_PATH
    },
    {
      id  = "keystore_store_pass"
      src = VEGITO_EXAMPLE_APPLICATION_MOBILE_ANDROID_RELEASE_KEYSTORE_STORE_PASS_BASE64_PATH
    }
  ]
  context = VEGITO_EXAMPLE_APPLICATION_MOBILE_DIR
  contexts = {
    "android" : LOCAL_ANDROID_DIR
    "approot" : VEGITO_EXAMPLE_APPLICATION_DIR
  }
  tags = [
    VEGITO_EXAMPLE_APPLICATION_MOBILE_IMAGE_LATEST,
    VEGITO_EXAMPLE_APPLICATION_MOBILE_IMAGE_TAG,
  ]
  cache-from = [
    USE_REGISTRY_CACHE ? "type=registry,ref=${VEGITO_EXAMPLE_APPLICATION_MOBILE_IMAGE_REGISTRY_CACHE_CI}" : "",
    "type=inline,ref=${VEGITO_EXAMPLE_APPLICATION_MOBILE_IMAGE_LATEST}",
    VEGITO_EXAMPLE_APPLICATION_MOBILE_IMAGE_DOCKER_BUILDX_LOCAL_CACHE_READ,
  ]
  cache-to = [
    # USE_REGISTRY_CACHE ? "type=registry,ref=${VEGITO_EXAMPLE_APPLICATION_MOBILE_IMAGE_REGISTRY_CACHE_CI},mode=max" : "type=inline"
    USE_REGISTRY_CACHE ? "type=registry,ref=${VEGITO_EXAMPLE_APPLICATION_MOBILE_IMAGE_REGISTRY_CACHE_CI},mode=max" : VEGITO_EXAMPLE_APPLICATION_MOBILE_IMAGE_DOCKER_BUILDX_CACHE_WRITE
  ]
  platforms = ["linux/amd64"]
}
