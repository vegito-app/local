terraform {
  backend "gcs" {
    bucket = "global-europe-west1-tf-state-dev"
    prefix = "terraform/state/"
  }
}
