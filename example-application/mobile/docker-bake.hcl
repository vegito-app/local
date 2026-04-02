variable "VEGITO_EXAMPLE_APPLICATION_MOBILE_DIR" {
  description = "Local directory for the mobile application"
  default     = "${VEGITO_EXAMPLE_APPLICATION_DIR}/mobile"
}

variable "VEGITO_EXAMPLE_APPLICATION_MOBILE_IMAGES_BASE" {
  default = "${VEGITO_EXAMPLE_APPLICATION_PUBLIC_IMAGES_BASE}:mobile"
}

variable "VEGITO_EXAMPLE_APPLICATION_MOBILE_IMAGE_TAG" {
  # default = notequal("", VERSION) ? "${VEGITO_LOCAL_PUBLIC_IMAGES_BASE}:mobile-${VERSION}" : ""
  default = "${VEGITO_EXAMPLE_APPLICATION_MOBILE_IMAGES_BASE}-${VERSION}"
}

variable "VEGITO_EXAMPLE_APPLICATION_MOBILE_IMAGE_LATEST" {
  default = "${VEGITO_EXAMPLE_APPLICATION_MOBILE_IMAGES_BASE}-latest"
}

variable "VEGITO_EXAMPLE_APPLICATION_MOBILE_IMAGE_DOCKER_BUILDX_LOCAL_CACHE" {
  default = "${VEGITO_EXAMPLE_APPLICATION_DIR}/mobile/.containers/buildx-cache"
}

variable "VEGITO_EXAMPLE_APPLICATION_MOBILE_IMAGE_DOCKER_BUILDX_CACHE_WRITE" {
  description = "local write cache for clarinet image build"
  default     = "type=local,mode=max,dest=${VEGITO_EXAMPLE_APPLICATION_MOBILE_IMAGE_DOCKER_BUILDX_LOCAL_CACHE}"
}

variable "VEGITO_EXAMPLE_APPLICATION_MOBILE_IMAGE_DOCKER_BUILDX_LOCAL_CACHE_READ" {
  description = "local read cache for clarinet image build (cannot be used before first write)"
  default     = "type=local,src=${VEGITO_EXAMPLE_APPLICATION_MOBILE_IMAGE_DOCKER_BUILDX_LOCAL_CACHE}"
}

variable "VEGITO_EXAMPLE_APPLICATION_MOBILE_IMAGE_REGISTRY_CACHE" {
  default = "${VEGITO_EXAMPLE_APPLICATION_CACHE_IMAGES_BASE}/mobile"
}

variable "VEGITO_EXAMPLE_APPLICATION_MOBILE_APK_BUILDER_IMAGE" {
  description = "Android Studio image to use for mobile application builds"
  default     = "${VEGITO_LOCAL_PUBLIC_IMAGES_BASE}:android-flutter-${LOCAL_VERSION}"
}

variable "VEGITO_EXAMPLE_APPLICATION_MOBILE_APK_BUILDER_IMAGE_LATEST" {
  description = "Android Studio image to use for mobile application builds"
  default     = "${VEGITO_LOCAL_PUBLIC_IMAGES_BASE}:android-flutter-latest"
}

variable "VEGITO_EXAMPLE_APPLICATION_MOBILE_APK_RUNNER_IMAGE" {
  description = "Android Studio image to use for mobile application builds"
  default     = "${VEGITO_LOCAL_PUBLIC_IMAGES_BASE}:android-appium-${LOCAL_VERSION}"
}

variable "VEGITO_EXAMPLE_APPLICATION_MOBILE_APK_RUNNER_IMAGE_LATEST" {
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

variable "VEGITO_EXAMPLE_APPLICATION_MOBILE_ANDROID_RELEASE_KEYSTORE_ALIAS_NAME" {
  description = "Alias name for the Android release keystore"
  default     = "vegito-local-release"
}

variable "VEGITO_EXAMPLE_APPLICATION_MOBILE_ANDROID_PACKAGE_NAME" {
  description = "Package name for the Android application"
  default     = "${INFRA_ENV}.vegito.app.android"
}

variable "VEGITO_EXAMPLE_APPLICATION_MOBILE_BUILDER_CONTEXT" {
  description = "Builder context (target:... or docker-image://...)"
  default     = "docker-image://${VEGITO_EXAMPLE_APPLICATION_MOBILE_APK_BUILDER_IMAGE}"
}

variable "VEGITO_EXAMPLE_APPLICATION_MOBILE_RUNNER_CONTEXT" {
  description = "Runner context (target:... or docker-image://...)"
  default     = "docker-image://${VEGITO_EXAMPLE_APPLICATION_MOBILE_APK_RUNNER_IMAGE}"
}

target "vegito-example-application-mobile" {
  args = {
    version              = VERSION
    android_package_name = VEGITO_EXAMPLE_APPLICATION_MOBILE_ANDROID_PACKAGE_NAME
    environment          = INFRA_ENV
    keystore_alias_name  = VEGITO_EXAMPLE_APPLICATION_MOBILE_ANDROID_RELEASE_KEYSTORE_ALIAS_NAME
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
    android = LOCAL_ANDROID_DIR
    approot = VEGITO_EXAMPLE_APPLICATION_DIR
    local   = LOCAL_DIR
    builder = VEGITO_EXAMPLE_APPLICATION_MOBILE_BUILDER_CONTEXT
    runner  = VEGITO_EXAMPLE_APPLICATION_MOBILE_RUNNER_CONTEXT
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

group "vegito-example-application-mobile-ci" {
  targets = [
    "vegito-example-application-mobile-version-ci",
    "vegito-example-application-mobile-latest-ci",
  ]
}

target "vegito-example-application-mobile-version-ci" {
  args = {
    version              = VERSION
    android_package_name = VEGITO_EXAMPLE_APPLICATION_MOBILE_ANDROID_PACKAGE_NAME
    environment          = INFRA_ENV
    keystore_alias_name  = VEGITO_EXAMPLE_APPLICATION_MOBILE_ANDROID_RELEASE_KEYSTORE_ALIAS_NAME
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
    android = LOCAL_ANDROID_DIR
    approot = VEGITO_EXAMPLE_APPLICATION_DIR
    local   = LOCAL_DIR
    builder = VEGITO_EXAMPLE_APPLICATION_MOBILE_BUILDER_CONTEXT
    runner  = VEGITO_EXAMPLE_APPLICATION_MOBILE_RUNNER_CONTEXT
  }
  tags = [
    VEGITO_EXAMPLE_APPLICATION_MOBILE_IMAGE_TAG,
  ]
  cache-from = [
    USE_REGISTRY_CACHE ? "type=registry,ref=${VEGITO_EXAMPLE_APPLICATION_MOBILE_IMAGE_REGISTRY_CACHE}" : "",
    "type=inline,ref=${VEGITO_EXAMPLE_APPLICATION_MOBILE_IMAGE_LATEST}",
  ]
  platforms = ["linux/amd64"]
}

target "vegito-example-application-mobile-latest-ci" {
  args = {
    apk_runner_appium_image = VEGITO_EXAMPLE_APPLICATION_MOBILE_APK_RUNNER_IMAGE
    version                 = VERSION
    android_package_name    = VEGITO_EXAMPLE_APPLICATION_MOBILE_ANDROID_PACKAGE_NAME
    environment             = INFRA_ENV
    keystore_alias_name     = VEGITO_EXAMPLE_APPLICATION_MOBILE_ANDROID_RELEASE_KEYSTORE_ALIAS_NAME
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
    android = LOCAL_ANDROID_DIR
    approot = VEGITO_EXAMPLE_APPLICATION_DIR
    local   = LOCAL_DIR
    builder = VEGITO_EXAMPLE_APPLICATION_MOBILE_BUILDER_CONTEXT
    runner  = VEGITO_EXAMPLE_APPLICATION_MOBILE_RUNNER_CONTEXT
  }
  tags = [
    VEGITO_EXAMPLE_APPLICATION_MOBILE_IMAGE_LATEST,
  ]
  cache-from = [
    USE_REGISTRY_CACHE ? "type=registry,ref=${VEGITO_EXAMPLE_APPLICATION_MOBILE_IMAGE_REGISTRY_CACHE}" : "",
    "type=inline,ref=${VEGITO_EXAMPLE_APPLICATION_MOBILE_IMAGE_LATEST}",
  ]
  cache-to = [
    USE_REGISTRY_CACHE ? "type=registry,ref=${VEGITO_EXAMPLE_APPLICATION_MOBILE_IMAGE_REGISTRY_CACHE},mode=max" : "type=inline"
  ]
  platforms = ["linux/amd64"]
}
