terraform {
  backend "gcs" {
    bucket = "utrade-europe-west1-tf-state"
    prefix = "terraform/state/staging"
  }
}
