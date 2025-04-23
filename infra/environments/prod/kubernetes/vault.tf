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
    "roles/iam.serviceAccountViewer",
  ])
  project = var.project_id
  role    = each.value
  member  = "serviceAccount:${google_service_account.vault_sa.email}"
}

resource "kubernetes_namespace" "vault" {
  metadata {
    name = "vault"
  }
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

resource "google_kms_key_ring_iam_binding" "vault_iam_kms_binding" {
  key_ring_id = google_kms_key_ring.vault.id
  role        = "roles/cloudkms.admin"

  members = [
    "serviceAccount:${google_service_account.vault_sa.email}",
  ]
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
      gcp_creds_secret = var.vault_gcp_credentials_secret_name
    })
  ]
  depends_on = [
    kubernetes_secret.vault_init_script,
    kubernetes_secret.vault_service_account
  ]
}

resource "helm_release" "vault" {
  name      = "vault-helm"
  namespace = kubernetes_namespace.vault.metadata[0].name

  repository = "https://helm.releases.hashicorp.com"
  chart      = "/tmp/vault"
  version    = var.helm_vault_chart_version

  values = [
    templatefile("${path.module}/vault-helm-values.yaml", {
      project_id = var.project_id
      region     = var.region

      k8s_namespace = kubernetes_namespace.vault.metadata[0].name
      key_ring      = google_kms_key_ring.vault.name
      crypto_key    = google_kms_crypto_key.vault.name

      service_account  = google_service_account.vault_sa.name
      gcp_creds_secret = var.vault_gcp_credentials_secret_name

      consul_helm_release_name = helm_release.consul.name
    })
  ]
  depends_on = [
    kubernetes_secret.vault_init_script,
    kubernetes_secret.vault_service_account,
    helm_release.consul
  ]
}

resource "kubernetes_secret" "vault_service_account" {
  metadata {
    name      = var.vault_gcp_credentials_secret_name
    namespace = kubernetes_namespace.vault.metadata[0].name
  }

  data = {
    "service-account.json" = base64decode(google_service_account_key.vault_sa_key.private_key)
  }
}


resource "kubernetes_secret" "vault_init_script" {
  provider = kubernetes

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


locals {
  vault_scheme = "http"
  vault_port   = 8200
  vault_host   = "${helm_release.vault.name}.${kubernetes_namespace.vault.metadata[0].name}.svc.cluster.local"
  vault_addr   = "${local.vault_scheme}://${local.vault_host}:${local.vault_port}"
}

resource "kubernetes_job" "vault_init_job" {
  provider = kubernetes

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
            value = "/etc/vault/secrets/${var.vault_gcp_credentials_secret_name}/service-account.json"
          }
          env {
            name  = "VAULT_TRANSIT_KEY_NAME"
            value = "recovery"
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
          name = "vault-data"

          empty_dir {}
        }
        volume {
          name = "init-script"
          secret {
            secret_name = "vault-init-script"
          }
        }
      }
    }
  }
  depends_on = [helm_release.vault]
}

resource "kubernetes_config_map" "vault_tf_code" {
  provider = kubernetes

  metadata {
    name      = "vault-tf-code"
    namespace = kubernetes_namespace.vault.metadata[0].name
  }

  data = {
    "main.tf"                 = file("${path.module}/../vault/main.tf")
    "outputs.tf"              = file("${path.module}/../vault/outputs.tf")
    "variables.tf"            = file("${path.module}/../vault/variables.tf")
    "provider.tf"             = file("${path.module}/../vault/provider.tf")
    ".terraform.lock.hcl"     = file("${path.module}/../vault/.terraform.lock.hcl")
    "terraform-apply-auto.sh" = file("${path.module}/../vault/terraform-apply-auto.sh")
    # add other files if required
  }
}

resource "kubernetes_service_account" "vault_tf_apply" {
  provider = kubernetes

  metadata {
    name      = "vault-tf-apply"
    namespace = kubernetes_namespace.vault.metadata[0].name
    annotations = {
      "iam.gke.io/gcp-service-account" = google_service_account.vault_tf_apply_sa.email
    }
  }
}

resource "kubernetes_secret" "vault_tf_apply_sa_secret" {
  provider = kubernetes

  metadata {
    name      = "vault-tf-apply-gcp-creds"
    namespace = kubernetes_namespace.vault.metadata[0].name
  }

  data = {
    "service-account.json" = base64decode(google_service_account_key.vault_tf_apply_sa_key.private_key)
  }
}

data "google_service_account_id_token" "vault_gcp_token" {
  target_service_account = google_service_account.vault_tf_apply_sa.email
  target_audience        = "${local.vault_addr}/vault/vault-tf-apply"
  include_email          = true
}

resource "kubernetes_secret" "vault_tf_apply_gcp_id_token" {
  metadata {
    name      = "vault-tf-apply-gcp-id-token"
    namespace = kubernetes_namespace.vault.metadata[0].name
  }

  data = {
    "id_token" = data.google_service_account_id_token.vault_gcp_token.id_token
  }
}

data "google_service_account_access_token" "vault_gcs_token" {
  target_service_account = google_service_account.vault_tf_apply_sa.email
  scopes                 = ["https://www.googleapis.com/auth/cloud-platform"]
  lifetime               = "300s"
}

resource "kubernetes_secret" "vault_tf_apply_gcs_token" {
  metadata {
    name      = "vault-tf-apply-gcs-token"
    namespace = kubernetes_namespace.vault.metadata[0].name
  }

  data = {
    "access_token" = data.google_service_account_access_token.vault_gcs_token.access_token
  }
}

resource "google_service_account" "vault_tf_apply_sa" {
  account_id   = "vault-tf-apply"
  display_name = "Vault Terraform Apply Job"
  project      = var.project_id
}

output "vault_tf_apply_sa" {
  value = google_service_account.vault_tf_apply_sa.email
}

resource "google_service_account_key" "vault_tf_apply_sa_key" {
  service_account_id = google_service_account.vault_tf_apply_sa.account_id
  private_key_type   = "TYPE_GOOGLE_CREDENTIALS_FILE"
}

resource "google_project_iam_member" "vault_tf_apply_bindings" {
  for_each = toset([
    "roles/storage.admin",
    "roles/storage.objectUser",
    "roles/iam.serviceAccountUser",
    "roles/iam.serviceAccountViewer",
    "roles/resourcemanager.projectIamAdmin",
    "roles/iam.workloadIdentityUser",
    "roles/iam.serviceAccountTokenCreator",
    "roles/viewer",
  ])
  project = var.project_id
  role    = each.value

  member = "serviceAccount:${google_service_account.vault_tf_apply_sa.email}"
}

resource "google_service_account_iam_member" "vault_tf_apply_token_creator" {
  service_account_id = google_service_account.vault_tf_apply_sa.name
  for_each = toset([
    "roles/iam.serviceAccountUser",
    "roles/iam.serviceAccountViewer",
    "roles/iam.workloadIdentityUser",
    "roles/iam.serviceAccountTokenCreator",
  ])
  role   = each.value
  member = "serviceAccount:${var.project_id}.svc.id.goog[vault/vault-tf-apply]"
}

resource "kubernetes_job" "vault_terraform_apply" {
  provider = kubernetes

  metadata {
    name      = "vault-tf-apply"
    namespace = kubernetes_namespace.vault.metadata[0].name
    annotations = {
      "iam.gke.io/gcp-service-account" = google_service_account.vault_tf_apply_sa.email
    }
  }

  spec {
    template {
      metadata {
        name = "vault-tf-apply"
        annotations = {
          "iam.gke.io/gcp-service-account" = google_service_account.vault_tf_apply_sa.email
        }
      }

      spec {
        service_account_name            = kubernetes_service_account.vault_tf_apply.metadata[0].name
        automount_service_account_token = true
        restart_policy                  = "Never"

        container {
          name = "terraform"
          # image = "hashicorp/terraform:1.7.5"
          image = "europe-west1-docker.pkg.dev/moov-dev-439608/docker-repository-public/moov-dev-439608:builder-latest"

          working_dir = "/workspace"
          command     = ["/bin/sh", "-c"]
          args = [<<EOT
          set -euo
          cp /workspace/terraform-apply-auto.sh /tmp/ 
          chmod +x /tmp/*.sh
          /tmp/terraform-apply-auto.sh  || sleep infinity
          EOT 
          ]

          env {
            name  = "VAULT_ADDR"
            value = local.vault_addr
          }
          env {
            name  = "TERRAFORM_VAULT_LOG_BODY"
            value = "true"
          }
          env {
            name  = "TF_DATA_DIR"
            value = "/tmp/terraform-cache"
          }
          volume_mount {
            name       = "vault-tf"
            mount_path = "/workspace"
          }
          volume_mount {
            name       = "vault-tf-apply-gcs-token"
            mount_path = "/etc/vault/secrets/access_token"
          }
          volume_mount {
            name       = "vault-tf-apply-gcp-id-token"
            mount_path = "/etc/vault/secrets/id_token"
          }
        }
        volume {
          name = "vault-tf"
          config_map {
            name = "vault-tf-code"
          }
        }
        volume {
          name = "vault-tf-apply-gcs-token"
          secret {
            secret_name = kubernetes_secret.vault_tf_apply_gcs_token.metadata[0].name
          }
        }
        volume {
          name = "vault-tf-apply-gcp-id-token"
          secret {
            secret_name = kubernetes_secret.vault_tf_apply_gcp_id_token.metadata[0].name
          }
        }
      }
    }
  }
  depends_on = [
    google_project_iam_member.vault_tf_apply_bindings,
    google_service_account_iam_member.vault_tf_apply_token_creator,
  ]
}
