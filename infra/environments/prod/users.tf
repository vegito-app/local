data "google_service_account" "production_root_admin_service_account" {
  account_id = "root-admin@moov-438615.iam.gserviceaccount.com"
}

# Ajoutez ensuite le rôle 'propriétaire' à ce compte de service pour le projet
resource "google_project_iam_member" "moov_staging" {
  project = "moov-staging-440506"
  role    = "roles/owner"
  member  = "serviceAccount:${data.google_service_account.production_root_admin_service_account.email}"
}

# Variables pour les développeurs et les environnements
variable "developers" {
  type = map(string)
  default = {
    # "alice@email.com"       = "alice-id",
    # "bob@email.com"         = "bob-id",
    "davidberich@gmail.com" = "david-berichon"
  }
}

variable "environments" {
  type = map(string)
  default = {
    "dev" = "moov-dev-439608",
    # "staging" = "moov-staging-123456",
    "prod" = "moov-438615"
  }
}

# Map des rôles par environnement
variable "roles_per_environment" {
  type = map(list(string))
  default = {
    dev     = ["roles/editor", "roles/secretmanager.secretAccessor", "roles/secretmanager.admin"] # Exemple : plus de permissions en dev
    staging = ["roles/viewer"]
    prod    = ["roles/viewer"] # Permissions plus restrictives en prod
  }
}

locals {
  flattened_for_each_map = flatten([
    for email, id in var.developers : [
      for env, project_id in var.environments : {
        name = "${id}-${env}"
        value = {
          email      = email
          env        = env
          project_id = project_id
          roles      = lookup(var.roles_per_environment, env, [])
        }
      }
    ]
  ])
  for_each_map = { for item in local.flattened_for_each_map : item.name => item.value }
}

# Boucle sur la map 'developers' pour créer un compte de service pour chaque développeur et environnement
resource "google_service_account" "developer_service_account" {
  for_each     = local.for_each_map
  account_id   = each.key
  project      = each.value.project_id
  display_name = "${each.key} service account for ${each.value.env}"
}

resource "google_storage_bucket_iam_member" "bucket_iam_member" {
  for_each = local.for_each_map
  bucket   = google_storage_bucket.bucket_tf_state_eu_global.name
  role     = "roles/storage.objectViewer"
  member   = "serviceAccount:${google_service_account.developer_service_account[each.key].email}"
}

resource "google_storage_bucket_iam_member" "bucket_locking_iam_member" {
  for_each = local.for_each_map
  bucket   = google_storage_bucket.bucket_tf_state_eu_global.name
  role     = "roles/storage.objectAdmin"
  member   = "serviceAccount:${google_service_account.developer_service_account[each.key].email}"
}

resource "google_project_iam_member" "artifact_registry_reader" {
  for_each = local.for_each_map
  project  = each.value.project_id
  role     = "roles/artifactregistry.reader"
  member   = "serviceAccount:${google_service_account.developer_service_account[each.key].email}"
}

# Attribuez le rôle de gestionnaire de clé à ce compte de service spécifique
resource "google_service_account_iam_member" "key_admin" {
  for_each = local.for_each_map

  service_account_id = google_service_account.developer_service_account[each.key].name

  role   = "roles/iam.serviceAccountKeyAdmin"
  member = "user:${each.value.email}"
}


# Attribuer un rôle IAM à un utilisateur sur ce compte de service spécifique
resource "google_project_iam_member" "developer_service_account_roles" {
  for_each = {
    for idx, role in flatten([
      for key, value in local.for_each_map : [
        for role in value.roles : {
          id = "${key}.${role}"
          # service_account_id = google_service_account.developer_service_account[key].id
          role       = role
          email      = google_service_account.developer_service_account[key].email
          project_id = value.project_id
        }
      ]
    ]) : idx => role
  }
  project = each.value.project_id
  role    = each.value.role
  member  = "serviceAccount:${each.value.email}"
}
