# Configures the provider to use the resource block's specified project for quota checks.
provider "google-beta" {
  alias                 = "no_user_project_override"
  user_project_override = true
}

# Enables required APIs.
resource "google_project_service" "google_vault_cluster_services" {
  project = var.project_id
  for_each = toset([
    "container.googleapis.com",
  ])
  service = each.key

  # Don't disable the service if the resource block is removed by accident.
  disable_on_destroy         = false
  disable_dependent_services = true
}

resource "google_container_cluster" "vault_cluster" {
  name               = "vault-cluster"
  location           = var.region
  initial_node_count = 1
  depends_on         = [google_project_service.google_vault_cluster_services]
  node_config {
    machine_type = "e2-small"
    oauth_scopes = [
      "https://www.googleapis.com/auth/cloud-platform"
    ]
  }
}

# Configure kubernetes provider with Oauth2 access token.
# https://registry.terraform.io/providers/hashicorp/google/latest/docs/data-sources/client_config
# This fetches a new token, which will expire in 1 hour.
data "google_client_config" "default" {
  # depends_on = [module.gke-cluster]
}

provider "kubernetes" {
  host                   = "https://${google_container_cluster.vault_cluster.endpoint}"
  cluster_ca_certificate = base64decode(google_container_cluster.vault_cluster.master_auth[0].cluster_ca_certificate)
  token                  = data.google_client_config.default.access_token
}
