variable "REPOSITORY" {
  default = "utrade-repository"
}

variable "BUILDER_IMAGE" {
  default = "${IMAGE_BASE}:builder"
}

default_git_tag = "latest"

variable "GIT_TAG" {
  default = default_git_tag
}

group "dev" {
  targets = ["builder"]
}

target "builder" {
  context = "."
  dockerfile = "builder.Dockerfile"
  tags = [ 
    BUILDER_IMAGE ,
    notequal("",GIT_TAG) ? "${IMAGE_BASE}:${GIT_TAG}-builder": "",
    "${IMAGE_BASE}:latest-builder", 
  ]
  cache-from = ["${IMAGE_BASE}:latest-builder"]
  cache-to = ["type=inline"]
  platforms = [
    "linux/amd64", 
    "linux/arm64"
    ]
  push = true
}

group "application" {
  targets = ["backend"]
}

variable "IMAGE_BASE" {
  default = "${REPOSITORY}/utrade"
}

default_backend_version = "latest-backend"

variable "VERSION" {
  default = default_backend_version
}

variable "BACKEND_IMAGE" {
  default = "${IMAGE_BASE}:${VERSION}-backend"
}

variable "GOOGLE_MAPS_API_KEY_FILE" {
  default = "frontend/google_maps_api_key"
}

variable "UTRADE_FIREBASE_API_KEY" {}
variable "UTRADE_FIREBASE_AUTH_DOMAIN" {}
variable "UTRADE_FIREBASE_DATABASE_URL" {}
variable "UTRADE_FIREBASE_PROJECT_ID" {}
variable "UTRADE_FIREBASE_STORAGE_BUCKET" {}
variable "UTRADE_FIREBASE_MESSAGING_SENDER_ID" {}
variable "UTRADE_FIREBASE_APP_ID" {}

target "backend" {
  context = "."
  dockerfile = "Dockerfile"
  args = {
    builder_image =  BUILDER_IMAGE
	  REACT_APP_UTRADE_VERSION = VERSION
	  REACT_APP_UTRADE_FIREBASE_API_KEY = UTRADE_FIREBASE_API_KEY
	  REACT_APP_UTRADE_FIREBASE_AUTH_DOMAIN = UTRADE_FIREBASE_AUTH_DOMAIN
	  REACT_APP_UTRADE_FIREBASE_DATABASE_URL = UTRADE_FIREBASE_DATABASE_URL
	  REACT_APP_UTRADE_FIREBASE_PROJECT_ID = UTRADE_FIREBASE_PROJECT_ID
	  REACT_APP_UTRADE_FIREBASE_STORAGE_BUCKET = UTRADE_FIREBASE_STORAGE_BUCKET
	  REACT_APP_UTRADE_FIREBASE_MESSAGING_SENDER_ID = UTRADE_FIREBASE_MESSAGING_SENDER_ID
	  REACT_APP_UTRADE_FIREBASE_APP_ID = UTRADE_FIREBASE_APP_ID
  }
  tags = [ 
    BACKEND_IMAGE,
    notequal("",GIT_TAG) ? "${IMAGE_BASE}:${GIT_TAG}-backend": "",
    "${IMAGE_BASE}:latest-backend", 
  ]
  platforms = [
    "linux/amd64",
    "linux/arm64"
  ]
  cache-from = ["${IMAGE_BASE}:latest-backend"]
  cache-to = ["type=inline"]
  push = true
  secret = [
    "type=file,id=google_maps_api_key,src=${GOOGLE_MAPS_API_KEY_FILE}"
  ]
}

variable "HOME" {
  default = null
}

target "default" {
}