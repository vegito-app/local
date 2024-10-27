module "infra" {
  source      = "../../gcloud"
  environment = "staging"

  application_backend_image = var.application_backend_image
  project_id                = var.project_id
  region                    = var.region
  repository_id             = var.repository_id
  public_repository_id      = var.public_repository_id
  ui_firebase_secret_id     = var.ui_firebase_secret_id
  ui_googlemaps_secret_id   = var.ui_googlemaps_secret_id
  cloud_storage_location    = "EU"
}
