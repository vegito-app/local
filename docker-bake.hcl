variable "LOCAL_ANDROID_APK_RUNNER_EMULATOR_IMAGE" {
  default = "${LOCAL_DOCKER_PUBLIC_IMAGES_BASE_NAME}:android-emulator-${VERSION}"
}
variable "LOCAL_ANDROID_APK_RUNNER_EMULATOR_IMAGE_LATEST" {
  default = "${LOCAL_DOCKER_PUBLIC_IMAGES_BASE_NAME}:android-emulator-latest"
}

variable "LOCAL_ANDROID_DIR" {
  default = "${LOCAL_DIR}/android"
}

group "local-android-runners" {
  description = "Build and push Android Studio images"
  targets = [
    "local-android-emulator",
    "local-android-appium",
  ]
}

group "local-android-runners-ci" {
  description = "Build and push Android Studio images"
  targets = [
    "local-android-emulator-ci",
    "local-android-appium-ci",
  ]
}

group "local-android-builders" {
  description = "Build and push Android Studio images"
  targets = [
    "local-android-studio",
  ]
}

group "local-android-builders-ci" {
  description = "Build and push Android Studio images"
  targets = [
    "local-android-studio-ci",
  ]
}

group "local-android" {
  targets = [
    "local-android-builders",
    "local-android-runners",
  ]
}

group "local-android-ci" {
  targets = [
    "local-android-builders-ci",
    "local-android-runners-ci",
  ]
}
