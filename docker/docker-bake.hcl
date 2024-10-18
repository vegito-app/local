variable "VERSION" {
  description = "current git tag or commit version"
  default     = "dev"
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

group "services-load-local-arch" {
  targets = [
    "backend",
    "github-runner",
  ]
}

group "services-push-multi-arch" {
  targets = [
    "backend-ci",
    "github-runner-ci",
  ]
}
