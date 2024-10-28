module "infra" {
  source      = "../../gcloud"
  environment = "staging"
  project_id  = var.project_id
  region      = var.region

  cloud_storage_location = "EU"

  application_backend_image = var.application_backend_image
  repository_id             = var.repository_id
  public_repository_id      = var.public_repository_id
  ui_firebase_secret_id     = var.ui_firebase_secret_id
  ui_googlemaps_secret_id   = var.ui_googlemaps_secret_id
}
