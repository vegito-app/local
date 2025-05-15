resource "vault_policy" "backend_application" {
  name = "backend-application"

  policy = <<EOT
path "transit/encrypt/user_wallet_recovery" {
  capabilities = ["update"]
}

path "transit/decrypt/user_wallet_recovery" {
  capabilities = ["update"]
}

path "auth/token/lookup-self" {
  capabilities = ["read"]
}
EOT
}

data "google_service_account" "application_backend_cloud_run_sa" {
  project    = var.project_id
  account_id = "production-application-backend"
}

resource "vault_gcp_auth_backend_role" "application_backend" {
  backend = "gcp"
  role    = "application-backend"
  type    = "iam"
  bound_projects = [
    var.project_id
  ]
  bound_service_accounts = [
    data.google_service_account.application_backend_cloud_run_sa.email
  ]
  token_policies = [vault_policy.backend_application.name]
}

data "google_service_account" "vault_tf_apply" {
  project    = var.project_id
  account_id = "vault-tf-apply"
}

resource "vault_gcp_auth_backend_role" "vault_tf_apply" {
  backend = "gcp"
  role    = "vault-tf-apply"
  type    = "iam"
  bound_projects = [
    var.project_id
  ]
  bound_service_accounts = [
    data.google_service_account.vault_tf_apply.email
  ]
  token_policies = ["admin"]
}

resource "vault_gcp_auth_backend_role" "vault_admin" {
  backend = "gcp"
  role    = "vault-admin"
  type    = "iam"
  bound_service_accounts = [
    data.google_service_account.vault_tf_apply.email,
    "root-admin@${var.project_id}.iam.gserviceaccount.com",
    "david-berichon-prod@${var.project_id}.iam.gserviceaccount.com",
  ]
  bound_projects = [var.project_id]
  token_policies = ["admin"]
}

resource "vault_mount" "transit" {
  path = "transit"
  type = "transit"
}
  
