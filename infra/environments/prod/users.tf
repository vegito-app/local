data "google_service_account" "production_root_admin_service_account" {
  account_id = "root-admin@moov-438615.iam.gserviceaccount.com"
}

variable "staging_project" {
  type    = string
  default = "moov-staging-440506"
}

variable "environments" {
  type = map(string)
  default = {
    "dev"     = "moov-dev-439608",
    "staging" = "moov-staging-440506",
    "prod"    = "moov-438615"
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

# Variables pour les développeurs et les environnements
variable "developers" {
  type = map(string)
  default = {
    # "alice@email.com"       = "alice-id",
    # "bob@email.com"         = "bob-id",
    "davidberich@gmail.com" = "david-berichon"
  }
}

# Ajoutez ensuite le rôle 'propriétaire' à ce compte de service pour le projet
resource "google_project_iam_member" "moov_staging" {
  project = var.staging_project
  role    = "roles/owner"
  member  = "serviceAccount:${data.google_service_account.production_root_admin_service_account.email}"
}

resource "google_project_iam_member" "artifactregistry_reader" {
  project = var.project_id
  role    = "roles/artifactregistry.reader"
  member  = "serviceAccount:${data.google_service_account.production_root_admin_service_account.email}"
}

locals {
  flattened_for_each_developer_map = flatten([
    for email, id in var.developers : [
      {
        id    = id
        email = email
      }
    ]
  ])
  flattened_for_each_developer_environment_map = flatten([
    for email, id in var.developers : [
      for env, project_id in var.environments : {
        name = "${id}-${env}"
        value = {
          email      = email
          id         = id
          env        = env
          project_id = project_id
          roles      = lookup(var.roles_per_environment, env, [])
        }
      }
    ]
  ])
  for_each_developer_environment_map = { for item in local.flattened_for_each_developer_environment_map : item.name => item.value }
}

# Boucle sur la map 'developers' pour créer un compte de service pour chaque développeur et environnement
resource "google_service_account" "developer_service_account" {
  for_each     = local.for_each_developer_environment_map
  account_id   = each.key
  project      = each.value.project_id
  display_name = "${each.key} service account for ${each.value.env}"
}

# Attribuer un rôle IAM à un utilisateur sur ce compte de service spécifique
resource "google_project_iam_member" "developer_service_account_roles" {
  for_each = {
    for idx, role in flatten([
      for key, value in local.for_each_developer_environment_map : [
        for role in value.roles : {
          id         = "${key}.${role}"
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

variable "staging_editors" {
  description = "Liste des utilisateurs staging editors"
  type        = list(string)
  default = [
    "serviceAccount:david-berichon-staging@moov-staging-440506.iam.gserviceaccount.com"
  ]
}

variable "staging_admin" {
  description = "Liste des utilisateurs staging editors"
  type        = list(string)
  default = [
    "serviceAccount:david-berichon-staging@moov-staging-440506.iam.gserviceaccount.com"
  ]
}

resource "google_storage_bucket_iam_member" "bucket_iam_member" {
  for_each = local.for_each_developer_environment_map
  bucket   = google_storage_bucket.bucket_tf_state_eu_global.name
  role     = "roles/storage.objectViewer"
  member   = "serviceAccount:${google_service_account.developer_service_account[each.key].email}"
}

resource "google_storage_bucket_iam_member" "bucket_locking_iam_member" {
  for_each = local.for_each_developer_environment_map
  bucket   = google_storage_bucket.bucket_tf_state_eu_global.name
  role     = "roles/storage.objectAdmin"
  member   = "serviceAccount:${google_service_account.developer_service_account[each.key].email}"
}
# Attribuez le rôle de gestionnaire de clé à ce compte de service spécifique
resource "google_service_account_iam_member" "key_admin" {
  for_each = local.for_each_developer_environment_map

  service_account_id = google_service_account.developer_service_account[each.key].name

  role   = "roles/iam.serviceAccountKeyAdmin"
  member = "user:${each.value.email}"
}

resource "google_project_iam_member" "artifact_registry_reader" {
  for_each = local.for_each_developer_environment_map
  project  = each.value.project_id
  role     = "roles/artifactregistry.reader"
  member   = "serviceAccount:${google_service_account.developer_service_account[each.key].email}"
}

resource "google_project_iam_binding" "staging_editor" {
  project = var.staging_project
  role    = "roles/editor"

  members = var.staging_editors
}

resource "google_project_iam_binding" "staging_secret_accessor" {
  project = var.staging_project
  role    = "roles/secretmanager.secretAccessor"
  members = var.staging_editors
}

resource "google_project_iam_binding" "staging_secret_admin" {
  project = var.staging_project
  role    = "roles/secretmanager.admin"
  members = var.staging_admin
}

resource "google_project_iam_binding" "staging_cloudfunction_admin" {
  project = var.staging_project
  role    = "roles/cloudfunctions.admin"
  members = var.staging_admin
}

resource "google_project_iam_binding" "staging_artifactregistry_admin" {
  project = var.staging_project
  role    = "roles/artifactregistry.admin"
  members = var.staging_admin
}

resource "google_project_iam_binding" "staging_artifactregistry_editor" {
  project = var.staging_project
  role    = "roles/artifactregistry.writer"
  members = var.staging_editors
}

resource "google_project_iam_binding" "staging_iam_admin" {
  project = var.staging_project
  role    = "roles/resourcemanager.projectIamAdmin"
  members = var.staging_admin
}

resource "google_project_iam_binding" "staging_storage_admin" {
  project = var.staging_project
  role    = "roles/storage.admin"
  members = var.staging_admin
}

resource "google_project_iam_binding" "staging_storage_editor" {
  project = var.staging_project
  role    = "roles/storage.objectViewer"
  members = var.staging_editors
}

resource "google_project_iam_binding" "staging_firebasedatabase_admin" {
  project = var.staging_project
  role    = "roles/firebasedatabase.admin"
  members = var.staging_admin
}

resource "google_project_iam_binding" "staging_firebasedatabase_editor" {
  project = var.staging_project
  role    = "roles/firebasedatabase.viewer"
  members = var.staging_admin
}

resource "google_project_iam_binding" "staging_datastore_owner" {
  project = var.staging_project
  role    = "roles/datastore.owner"
  members = var.staging_admin
}

resource "google_project_iam_binding" "staging_roles_admin" {
  project = var.staging_project
  role    = "roles/iam.roleAdmin"
  members = var.staging_admin
}

resource "google_project_iam_binding" "staging_datastore_editor" {
  project = var.staging_project
  role    = "roles/datastore.viewer"
  members = var.staging_editors
}

resource "google_project_iam_binding" "staging_service_account_user_as_admin" {
  project = var.staging_project
  role    = "roles/iam.serviceAccountUser"
  members = var.staging_admin
}

# Clés API Google Maps pour chaque développeur
resource "google_apikeys_key" "developer_google_maps_api_key" {
  for_each     = var.developers
  name         = "web-google-maps-api-key-${each.value}"
  display_name = "Web Maps API Key"
  restrictions {
    # Limiter l'usage de cette clé API aux requêtes provenant du domaine localhost
    browser_key_restrictions {
      allowed_referrers = ["localhost"]
    }

    # Restreindre aux API Google Maps spécifiques
    api_targets {
      service = "maps-backend.googleapis.com"
    }
  }
}

# Stocker chaque clé dans Google Secret Manager
resource "google_secret_manager_secret" "developer_maps_api_secret" {
  for_each  = var.developers
  secret_id = "maps-api-key-secret-${each.value}"
  replication {
    auto {
    }
  }
}

resource "google_secret_manager_secret_version" "developer_maps_api_secret_version" {
  for_each    = var.developers
  secret      = google_secret_manager_secret.developer_maps_api_secret[each.key].id
  secret_data = google_apikeys_key.developer_google_maps_api_key[each.key].key_string
}

# Accès au secret pour chaque compte de service
resource "google_secret_manager_secret_iam_member" "allow_service_account_access" {
  for_each  = local.for_each_developer_environment_map
  secret_id = "maps-api-key-secret-${each.value.id}"
  role      = "roles/secretmanager.secretAccessor"
  member    = "serviceAccount:${google_service_account.developer_service_account[each.key].email}"
}
