variable "VERSION" {
  description = "current git tag or commit version"
  default     = "local"
}
variable "LOCAL_VERSION" {
  description = "version of vegito-app/local repository"
}
variable "VEGITO_EXAMPLE_APPLICATION_DIR" {
  default = "."
}
variable "INFRA_ENV" {
  description = "production, staging or dev"
  default     = "dev"
}

variable "VEGITO_APP_PUBLIC_IMAGES_BASE" {
  default = "${VEGITO_PUBLIC_REPOSITORY}/vegito-app"
}

variable "VEGITO_APP_PRIVATE_IMAGES_BASE" {
  default = "${VEGITO_PRIVATE_REPOSITORY}/vegito-app"
}

variable "LOCAL_ROBOTFRAMEWORK_IMAGE_VERSION" {
  default = "${VEGITO_LOCAL_PUBLIC_IMAGES_BASE}:robotframework-${LOCAL_VERSION}"
}

group "example-applications" {
  targets = [
    "example-application-backend",
    "example-application-mobile",
    "example-application-tests",
  ]
}

group "example-applications-ci" {
  targets = [
    "example-application-backend-ci",
    "example-application-mobile-ci",
    "example-application-tests-ci",
  ]
}

# docker buildx bake
# /workspaces/vegito-app/local/docker/docker-bake.hcl
# /workspaces/vegito-app/local/docker-bake.hcl
# /workspaces/vegito-app/local/clarinet-devnet/docker-bake.hcl
# /workspaces/vegito-app/local/robotframework/docker-bake.hcl
# /workspaces/vegito-app/local/firebase-emulators/docker-bake.hcl
# /workspaces/vegito-app/local/vault-dev/docker-bake.hcl
# /workspaces/vegito-app/local/android/docker-bake.hcl
# /workspaces/vegito-app/local/android/appium/docker-bake.hcl
# /workspaces/vegito-app/local/android/emulator/docker-bake.hcl
# /workspaces/vegito-app/local/android/flutter/docker-bake.hcl
# /workspaces/vegito-app/local/android/studio/docker-bake.hcl
# /workspaces/vegito-app/local/example-application/docker-bake.hcl
# /workspaces/vegito-app/local/example-application/backend/docker-bake.hcl
# /workspaces/vegito-app/local/example-application/mobile/docker-bake.hcl
# /workspaces/vegito-app/local/example-application/tests/docker-bake.hcl
# /workspaces/vegito-app/local/github-actions/docker-bake.hcl --print local-applications-ci
