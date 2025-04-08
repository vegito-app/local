resource "google_service_account" "vault_sa" {
  account_id   = "vault-sa"
  display_name = "Vault Service Account"
  project      = var.project_id
  lifecycle {
    prevent_destroy = true
  }
}

resource "google_service_account_key" "vault_sa_key" {
  service_account_id = google_service_account.vault_sa.account_id
  private_key_type   = "TYPE_GOOGLE_CREDENTIALS_FILE"
}

resource "google_project_iam_member" "vault_sa_role" {
  for_each = toset([
    "roles/cloudkms.viewer",
    "roles/cloudkms.cryptoKeyEncrypterDecrypter",
    "roles/cloudkms.signerVerifier",
    "roles/storage.admin",
  ])
  project = var.project_id
  role    = each.value
  member  = "serviceAccount:${google_service_account.vault_sa.email}"
}

resource "google_kms_key_ring" "vault" {
  name     = "vault-keyring"
  location = "global"
  project  = var.project_id
}

resource "google_kms_crypto_key" "vault" {
  name            = "vault-key"
  key_ring        = google_kms_key_ring.vault.id
  rotation_period = "100000s"
  lifecycle {
    prevent_destroy = true
  }
}

resource "google_kms_crypto_key_iam_member" "vault_sa_key_encrypter" {
  for_each = toset([
    "roles/cloudkms.cryptoKeyEncrypterDecrypter",
    "roles/cloudkms.signerVerifier",
  ])
  crypto_key_id = google_kms_crypto_key.vault.id
  role          = each.value
  member        = "serviceAccount:${google_service_account.vault_sa.email}"
}

resource "google_kms_key_ring_iam_binding" "vault_iam_kms_binding" {
  key_ring_id = google_kms_key_ring.vault.id
  role        = "roles/cloudkms.admin"

  members = [
    "serviceAccount:${google_service_account.vault_sa.email}",
  ]
}

variable "vault_sa_kubernetes_secret_name" {
  default     = "vault-gcp-credentials"
  description = "kubernetes secrets contains vault GCP credentials"
}

resource "kubernetes_secret" "vault_service_account" {
  metadata {
    name      = var.vault_sa_kubernetes_secret_name
    namespace = kubernetes_namespace.vault.metadata[0].name
  }

  data = {
    "service-account.json" = base64decode(google_service_account_key.vault_sa_key.private_key)
  }
}

resource "kubernetes_namespace" "vault" {
  metadata {
    name = "vault"
  }
}

resource "kubernetes_secret" "vault_init_script" {
  metadata {
    name      = "vault-init-script"
    namespace = kubernetes_namespace.vault.metadata[0].name
  }

  data = {
    "init.sh" = templatefile("${path.module}/vault_init_job.sh-template", {
      project_id            = var.project_id
      vault_service_account = google_service_account.vault_sa.email
    })
  }
}

provider "helm" {
  kubernetes {
    host                   = "https://${google_container_cluster.vault_cluster.endpoint}"
    cluster_ca_certificate = base64decode(google_container_cluster.vault_cluster.master_auth[0].cluster_ca_certificate)
    token                  = data.google_client_config.default.access_token
  }
}

resource "helm_release" "vault" {
  name      = "vault-helm"
  namespace = kubernetes_namespace.vault.metadata[0].name

  repository = "https://helm.releases.hashicorp.com"
  chart      = "vault"
  version    = var.helm_vault_chart_version

  values = [
    templatefile("${path.module}/vault-helm-values.yaml", {
      project_id = var.project_id
      region     = var.region

      key_ring   = google_kms_key_ring.vault.name
      crypto_key = google_kms_crypto_key.vault.name

      service_account  = google_service_account.vault_sa.name
      gcp_creds_secret = var.vault_sa_kubernetes_secret_name

      consul_helm_release_name = helm_release.consul.name
    })
  ]
  depends_on = [
    kubernetes_secret.vault_init_script,
    kubernetes_secret.vault_service_account,
    helm_release.consul
  ]
}

locals {
  vault_scheme = "http"
  vault_port   = 8200
  vault_host   = "${helm_release.vault.name}.${kubernetes_namespace.vault.metadata[0].name}.svc.cluster.local"
  vault_addr   = "${local.vault_scheme}://${local.vault_host}:${local.vault_port}"
}

resource "kubernetes_job" "vault_init_job" {
  metadata {
    name      = "vault-init-job"
    namespace = kubernetes_namespace.vault.metadata[0].name
  }

  spec {
    template {
      metadata {
        name = "vault-init-job"
      }

      spec {
        restart_policy = "Never"

        container {
          name  = "vault-init"
          image = "hashicorp/vault:${var.vault_version}"

          command = ["/bin/sh", "/vault/init/init.sh"]
          env {
            name  = "VAULT_ADDR"
            value = local.vault_addr
          }
          env {
            name  = "VAULT_HOST"
            value = local.vault_host
          }
          env {
            name  = "VAULT_PORT"
            value = local.vault_port
          }
          env {
            name  = "GOOGLE_REGION"
            value = "global"
          }
          env {
            name  = "GOOGLE_PROJECT"
            value = var.project_id
          }
          env {
            name  = "GOOGLE_APPLICATION_CREDENTIALS"
            value = "/etc/vault/secrets/${var.vault_sa_kubernetes_secret_name}/service-account.json"
          }

          volume_mount {
            name       = "init-script"
            mount_path = "/vault/init"
            read_only  = true
          }

          volume_mount {
            name       = "vault-data"
            mount_path = "/vault/data"
            read_only  = true
          }
        }

        volume {
          name = "init-script"

          secret {
            secret_name = kubernetes_secret.vault_init_script.metadata[0].name
            items {
              key  = "init.sh"
              path = "init.sh"
            }
          }
        }

        volume {
          name = "vault-data"

          empty_dir {}
        }
      }
    }
  }
  depends_on = [helm_release.vault]
}
