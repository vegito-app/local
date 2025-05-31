
locals {
  staging_admin_service_accounts = concat(local.production_admin_service_accounts, [
    # "serviceAccount:david-berichon-staging@moov-staging-440506.iam.gserviceaccount.com"
  ])
  staging_editor_service_accounts = concat(local.production_editor_service_accounts, [
    "serviceAccount:david-berichon-staging@moov-staging-440506.iam.gserviceaccount.com"
  ])
}

module "staging_users" {
  project_id  = var.staging_project
  source      = "../../users"
  users_email = var.users_email
  environment = "staging"
}

module "staging_admin_members" {
  source                = "../../roles"
  project_id            = var.staging_project
  user_service_accounts = local.staging_admin_service_accounts

  roles = var.admin_user_roles
}

module "staging_editor_members" {
  source                = "../../roles"
  project_id            = var.staging_project
  user_service_accounts = local.staging_editor_service_accounts

  roles = var.editor_user_roles
}

module "staging_root_admin_members" {
  source                = "../../roles"
  project_id            = var.staging_project
  user_service_accounts = local.root_admin_service_accounts

  roles = var.root_admin_user_roles
}

data "google_service_account" "staging_user_service_account" {
  project    = var.staging_project
  for_each   = var.users_email
  account_id = "${each.value}-staging"
}

data "google_artifact_registry_repository" "staging_docker_private_repository" {
  project       = var.staging_project
  location      = var.region
  repository_id = "docker-repository-private"
}

resource "google_artifact_registry_repository_iam_member" "staging_docker_private_repository_viewer" {
  for_each   = var.users_email
  location   = data.google_artifact_registry_repository.staging_docker_private_repository.location
  repository = data.google_artifact_registry_repository.staging_docker_private_repository.repository_id
  role       = "roles/artifactregistry.reader"
  member     = "serviceAccount:${data.google_service_account.staging_user_service_account[each.key].email}"
}
