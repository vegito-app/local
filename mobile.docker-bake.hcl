target "vegito-example-application-mobile-builder" {
  args = {
    apk_builder_image = VEGITO_EXAMPLE_APPLICATION_MOBILE_APK_BUILDER_IMAGE
  }
  context    = VEGITO_EXAMPLE_APPLICATION_MOBILE_DIR
  dockerfile = "builder.Dockerfile"
}

target "vegito-example-application-mobile-runner" {
  args = {
    apk_runner_appium_image = VEGITO_EXAMPLE_APPLICATION_MOBILE_APK_RUNNER_APPIUM_IMAGE
  }
  context    = VEGITO_EXAMPLE_APPLICATION_MOBILE_DIR
  dockerfile = "runner.Dockerfile"
}
