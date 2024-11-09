terraform {
  backend "gcs" {
    bucket = "global-europe-west1-tf-state"
    prefix = "terraform/state/staging/secrets"
  }
}
