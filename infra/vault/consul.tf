resource "helm_release" "consul" {
  name      = "consul-helm"
  namespace = kubernetes_namespace.vault.metadata[0].name

  repository = "https://helm.releases.hashicorp.com"
  chart      = "consul"
  version    = "1.6.3"

  values = [
    templatefile("${path.module}/consul-helm-values.yaml", {
      project_id       = var.project_id
      region           = var.region
      key_ring         = google_kms_key_ring.vault.name
      crypto_key       = google_kms_crypto_key.vault.name
      gcp_creds_secret = var.vault_sa_kubernetes_secret_name
    })
  ]
  depends_on = [
    kubernetes_secret.vault_init_script,
    kubernetes_secret.vault_service_account
  ]
}
