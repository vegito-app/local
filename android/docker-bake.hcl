variable "LOCAL_ANDROID_APK_RUNNER_EMULATOR_IMAGE_LATEST" {
  default = "${VEGITO_LOCAL_PUBLIC_IMAGES_BASE}:local-android-emulator-latest"
}

group "local-android-runner" {
  description = "Build and push Android Studio images"
  targets = [
    "local-android-emulator",
  ]
}

group "local-android-runner-ci" {
  description = "Build and push Android Studio images"
  targets = [
    "local-android-emulator-ci",
  ]
}

group "local-android-builder" {
  description = "Build and push Android Studio images"
  targets = [
    "local-android-flutter",
    "local-android-appium",
  ]
}

group "local-android-builder-ci" {
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
