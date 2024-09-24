terraform {
  backend "gcs" {
    bucket = "utrade-us-central1-tf-state-prod"
    prefix = "terraform/state"
  }
}
