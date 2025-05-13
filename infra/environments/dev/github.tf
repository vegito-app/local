resource "google_service_account" "github_actions" {
  account_id   = "github-actions-main"
  display_name = "Github Actions"
}

resource "google_service_account_iam_member" "github_actions" {
  for_each = toset([
    "roles/iam.serviceAccountUser",
    "roles/iam.serviceAccountTokenCreator",
  ])
  service_account_id = google_service_account.github_actions.name
  role               = each.value
  member             = "serviceAccount:${google_service_account.github_actions.email}"
}

# Workload Identity Federation pour GitHub Actions
resource "google_iam_workload_identity_pool" "github_pool" {
  workload_identity_pool_id = "github-pool"
  display_name              = "GitHub OIDC Pool"
}

resource "google_iam_workload_identity_pool_provider" "github_provider" {
  workload_identity_pool_id          = google_iam_workload_identity_pool.github_pool.workload_identity_pool_id
  workload_identity_pool_provider_id = "github"
  display_name                       = "GitHub Actions Provider"
  description                        = "OIDC provider for GitHub Actions CI/CD for refactored-winner"
  disabled                           = false

  attribute_mapping = {
    "google.subject"               = "assertion.sub"
    "attribute.actor"              = "assertion.actor"
    "attribute.repository"         = "assertion.repository"
    "attribute.ref"                = "assertion.ref"
    "attribute.ref_type"           = "assertion.ref_type"
    "attribute.repository_owner_id"= "assertion.repository_owner_id"
  }

attribute_condition = <<EOT
  attribute.repository == "7d4b9/refactored-winner" &&
  (attribute.ref == "refs/heads/main" || attribute.ref == "refs/heads/dev") &&
  attribute.ref_type == "branch"
EOT

  oidc {
    issuer_uri = "https://token.actions.githubusercontent.com"
  }
}

resource "google_service_account_iam_member" "github_actions_wif_user" {
  service_account_id = google_service_account.github_actions.name
  role               = "roles/iam.workloadIdentityUser"
  member             = "principalSet://iam.googleapis.com/${google_iam_workload_identity_pool.github_pool.name}/attribute.repository/7d4b9/refactored-winner"
}

data "google_storage_bucket" "dev_global_tf_state_bucket" {
  name = "global-${var.region}-tf-state-dev"
}
resource "google_storage_bucket_iam_member" "github_actions" {
  for_each = toset([
    "roles/storage.objectAdmin",
    "roles/storage.admin",
  ])
  role   = each.value
  bucket = data.google_storage_bucket.dev_global_tf_state_bucket.name
  member = "serviceAccount:${google_service_account.github_actions.email}"
}

data "google_artifact_registry_repository" "private_docker_repository" {
  location      = var.region
  repository_id = "docker-repository-private"
}
resource "google_artifact_registry_repository_iam_member" "github_actions_private_repo_read_member" {
  for_each = toset([
    "roles/artifactregistry.reader",
    "roles/artifactregistry.writer",
  ])
  location   = var.region
  repository = data.google_artifact_registry_repository.private_docker_repository.name
  role       = each.value
  member     = "serviceAccount:${google_service_account.github_actions.email}"
}

data "google_artifact_registry_repository" "public_docker_repository" {
  location      = var.region
  repository_id = "docker-repository-public"
}
resource "google_artifact_registry_repository_iam_member" "github_actions_public_repo_write_member" {
  provider = google
  for_each = toset([
    "roles/artifactregistry.writer",
    "roles/artifactregistry.reader",
  ])
  location   = var.region
  repository = data.google_artifact_registry_repository.public_docker_repository.name
  role       = each.value
  member     = "serviceAccount:${google_service_account.github_actions.email}"
}

resource "google_storage_bucket_iam_member" "github_actions_public_strorage_object_user" {
  for_each = toset([
    "roles/storage.objectAdmin",
    "roles/storage.admin",
  ])
  role   = each.value
  bucket = data.google_storage_bucket.dev_global_tf_state_bucket.name
  member = "serviceAccount:${google_service_account.github_actions.email}"
}

resource "google_storage_bucket_iam_member" "github_actions_private_strorage_object_user" {
  for_each = toset([
    "roles/storage.objectAdmin",
    "roles/storage.admin",
  ])
  role   = each.value
  bucket = data.google_storage_bucket.dev_global_tf_state_bucket.name
  member = "serviceAccount:${google_service_account.github_actions.email}"
}

output "wif_provider_id" {
  value = google_iam_workload_identity_pool_provider.github_provider.id
}
output "wif_pool_id" {
  value = google_iam_workload_identity_pool.github_pool.id
}
output "wif_pool_name" {
  value = google_iam_workload_identity_pool.github_pool.name
}
output "wif_pool_provider_name" {
  value = google_iam_workload_identity_pool_provider.github_provider.name
}
output "wif_pool_provider_id" {
  value = google_iam_workload_identity_pool_provider.github_provider.id
}
output "wif_pool_provider_issuer_uri" {
  value = google_iam_workload_identity_pool_provider.github_provider.oidc[0].issuer_uri
}
output "wif_pool_provider_attribute_mapping" {
  value = google_iam_workload_identity_pool_provider.github_provider.attribute_mapping
}
output "wif_pool_provider_attribute_mapping_github" {
  value = google_iam_workload_identity_pool_provider.github_provider.attribute_mapping["attribute.repository"]
}
output "wif_pool_provider_attribute_mapping_github_actions" {
  value = google_iam_workload_identity_pool_provider.github_provider.attribute_mapping["google.subject"]
}
output "wif_pool_provider_attribute_mapping_github_actions_actor" {
  value = google_iam_workload_identity_pool_provider.github_provider.attribute_mapping["attribute.actor"]
}
output "wif_pool_provider_attribute_mapping_github_actions_repository" {
  value = google_iam_workload_identity_pool_provider.github_provider.attribute_mapping["attribute.repository"]
}
output "wif_service_account" {
  value = google_service_account.github_actions.email
}
