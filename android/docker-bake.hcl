variable "LOCAL_ANDROID_APK_RUNNER_EMULATOR_IMAGE" {
  default = "${VEGITO_LOCAL_PUBLIC_IMAGES_BASE}:android-emulator-${VERSION}"
}
variable "LOCAL_ANDROID_APK_RUNNER_EMULATOR_IMAGE_LATEST" {
  default = "${VEGITO_LOCAL_PUBLIC_IMAGES_BASE}:android-emulator-latest"
}

variable "LOCAL_ANDROID_DIR" {
  default = "${LOCAL_DIR}/android"
}

group "local-android-runners" {
  description = "Build and push Android Studio images"
  targets = [
    "local-android-emulator",
  ]
}

group "local-android-runners-ci" {
  description = "Build and push Android Studio images"
  targets = [
    "local-android-emulator-ci",
  ]
}

group "local-android-builders" {
  description = "Build and push Android Studio images"
  targets = [
    "local-android-flutter",
    "local-android-appium",
  ]
}

group "local-android-builders-ci" {
  description = "Build and push Android Studio images"
  targets = [
    "local-android-flutter-ci",
    "local-android-appium-ci",
  ]
}

group "local-android-services" {
  description = "Build and push Android Studio images"
  targets = [
    "local-android-studio",
  ]
}

group "local-android-services-ci" {
  description = "Build and push Android Studio images"
  targets = [
    "local-android-studio-ci",
  ]
}

group "local-android" {
  targets = [
    "local-android-appium",
    "local-android-emulator",
    "local-android-flutter",
    "local-android-studio"
  ]
}

group "local-android-ci" {
  targets = [
    "local-android-appium-ci",
    "local-android-emulator-ci",
    "local-android-flutter-ci",
    "local-android-studio-ci"
  ]
}
