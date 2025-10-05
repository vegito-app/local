variable "VERSION" {
  description = "current git tag or commit version"
  default     = "local"
}
variable "LOCAL_EXAMPLE_APPLICATION_DIR" {
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
group "local-example-application" {
  targets = [
    "local-example-application-backend",
    "local-example-application-mobile",
  ]
}
group "local-example-application-ci" {
  targets = [
    "local-example-application-backend",
    "local-example-application-mobile",
  ]
}
