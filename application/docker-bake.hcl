variable "VERSION" {
  description = "current git tag or commit version"
  default     = "local"
}
variable "APPLICATION_DIR" {
  default = "."
}
variable "INFRA_ENV" {
  description = "production, staging or dev"
  default     = "dev"
}

variable "VEGITO_APP_PUBLIC_IMAGES_BASE" {
  default = "${VEGITO_LOCAL_PUBLIC_REPOSITORY}/vegito-app"
}

variable "VEGITO_APP_PRIVATE_IMAGES_BASE" {
  default = "${VEGITO_LOCAL_PRIVATE_REPOSITORY}/vegito-app"
}
group "local-application-services-host-arch-load" {
  targets = [
    "local-application-backend",
    "local-application-mobile",
    # "application-images-vision-cleaner",
    # "application-images-vision-moderator",
  ]
}
group "local-application-services-multi-arch-push" {
  targets = [
    "local-application-backend",
    "local-application-mobile",
    # "application-images-vision-cleaner",
    # "application-images-vision-moderator",
  ]
}
