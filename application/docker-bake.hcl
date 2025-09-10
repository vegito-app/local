variable "VERSION" {
  description = "current git tag or commit version"
  default     = "local"
}
variable "LOCAL_APPLICATION_DIR" {
  default = "."
}

group "local-application" {
  targets = [
    "local-application-backend",
    "local-application-mobile",
    # "application-images-vision-cleaner",
    # "application-images-vision-moderator",
  ]
}
group "local-application-ci" {
  targets = [
    "local-application-backend",
    "local-application-mobile",
    # "application-images-vision-cleaner",
    # "application-images-vision-moderator",
  ]
}
