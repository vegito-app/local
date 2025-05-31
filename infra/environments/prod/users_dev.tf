
module "dev_users" {
  source      = "../../users"
  project_id  = var.dev_project
  users_email = var.users_email
  environment = "dev"
}

locals {
  dev_admin_service_accounts = concat(local.staging_admin_service_accounts, [
    # "serviceAccount:david-berichon-dev@moov-dev-439608.iam.gserviceaccount.com"
  ])
  dev_editor_service_accounts = concat(local.staging_editor_service_accounts, [
    "serviceAccount:david-berichon-dev@moov-dev-439608.iam.gserviceaccount.com"
  ])
}

module "dev_admin_members" {
  source                = "../../roles"
  project_id            = var.dev_project
  user_service_accounts = local.dev_admin_service_accounts

  roles = var.admin_user_roles
}

module "dev_editor_members" {
  source                = "../../roles"
  project_id            = var.dev_project
  user_service_accounts = local.dev_editor_service_accounts

  roles = var.editor_user_roles
}

module "dev_root_admin_members" {
  source                = "../../roles"
  project_id            = var.dev_project
  user_service_accounts = local.root_admin_service_accounts

  roles = var.root_admin_user_roles
}

data "google_service_account" "dev_user_service_account" {
  project    = var.dev_project
  for_each   = var.users_email
  account_id = "${each.value}-dev"
}

data "google_artifact_registry_repository" "dev_docker_private_repository" {
  project       = var.dev_project
  location      = var.region
  repository_id = "docker-repository-private"
}

resource "google_artifact_registry_repository_iam_member" "dev_docker_private_repository_reader" {
  for_each   = var.users_email
  location   = data.google_artifact_registry_repository.dev_docker_private_repository.location
  repository = data.google_artifact_registry_repository.dev_docker_private_repository.repository_id
  role       = "roles/artifactregistry.reader"
  member     = "serviceAccount:${data.google_service_account.dev_user_service_account[each.key].email}"
}

resource "google_artifact_registry_repository_iam_member" "dev_docker_private_repository_writer" {
  for_each   = var.users_email
  location   = data.google_artifact_registry_repository.dev_docker_private_repository.location
  repository = data.google_artifact_registry_repository.dev_docker_private_repository.repository_id
  role       = "roles/artifactregistry.writer"
  member     = "serviceAccount:${data.google_service_account.dev_user_service_account[each.key].email}"
}
