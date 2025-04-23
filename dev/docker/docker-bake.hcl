variable "VERSION" {
  description = "current git tag or commit version"
  default     = "dev"
}

variable "DOCKER_VERSION" {
  description = "current docker version"
  default     = "28.0.2"
}

variable "INFRA_ENV" {
  description = "production, staging or dev"
  default     = "dev"
}

variable "REPOSITORY" {
  default = "${INFRA_ENV}-docker-repository"
}

variable "PUBLIC_REPOSITORY" {
  default = "${INFRA_ENV}-docker-repository-public"
}

variable "GOOGLE_CLOUD_PROJECT_ID" {
  default = "default"
}

variable "PUBLIC_IMAGES_BASE" {
  default = "${PUBLIC_REPOSITORY}/${GOOGLE_CLOUD_PROJECT_ID}"
}

variable "PRIVATE_IMAGES_BASE" {
  default = "${REPOSITORY}/${GOOGLE_CLOUD_PROJECT_ID}"
}

variable "platforms" {
  default = [
    "linux/amd64",
    "linux/arm64"
  ]
}

group "services-load-local-arch" {
  targets = [
    "android-studio",
    "backend",
    "clarinet",
    "firebase-emulators",
    "github-action-runner",
    "vault-dev",
  ]
}

group "services-push-multi-arch" {
  targets = [
    "android-studio-ci",
    "backend-ci",
    "clarinet-ci",
    "firebase-emulators-ci",
    "github-action-runner-ci",
    "vault-dev-ci",
  ]
}
