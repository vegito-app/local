# Configure kubernetes provider with Oauth2 access token.
# https://registry.terraform.io/providers/hashicorp/google/latest/docs/data-sources/client_config
# This fetches a new token, which will expire in 1 hour.
data "google_client_config" "default" {}

locals {
  kubernetes_host = "https://${google_container_cluster.vault_cluster.endpoint}"
}

provider "kubernetes" {
  config_path = "~/.kube/config"

  host                   = local.kubernetes_host
  cluster_ca_certificate = base64decode(google_container_cluster.vault_cluster.master_auth[0].cluster_ca_certificate)
  token                  = data.google_client_config.default.access_token
}

provider "helm" {
  kubernetes {
    host                   = local.kubernetes_host
    cluster_ca_certificate = base64decode(google_container_cluster.vault_cluster.master_auth[0].cluster_ca_certificate)
    token                  = data.google_client_config.default.access_token
  }
}
