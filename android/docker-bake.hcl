variable "LOCAL_ANDROID_APK_RUNNER_EMULATOR_IMAGE_LATEST" {
  default = "${VEGITO_LOCAL_PUBLIC_IMAGES_BASE}:local-android-emulator-latest"
}

group "local-android-builder-host-arch-load" {
  description = "Build and push Android Studio images"
  targets = [
    "local-android-emulator",
    "local-android-flutter",
  ]
}

group "local-android-builder-multi-arch-push" {
  description = "Build and push Android Studio images"
  targets = [
    "local-android-emulator",
    "local-android-flutter",
  ]
}

group "local-android-services-host-arch-load" {
  description = "Build and push Android Studio images"
  targets = [
    "local-android-studio-ci",
    "local-android-appium-ci",
  ]
}

group "local-android-services-multi-arch-push" {
  description = "Build and push Android Studio images"
  targets = [
    "local-android-studio-ci",
    "local-android-appium-ci",
  ]
}
