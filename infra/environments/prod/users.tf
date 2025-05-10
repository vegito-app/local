

# Map des rôles par environnement par défaut
variable "default_roles_per_environment" {
  type = map(list(string))
  default = {
    dev = [
      "roles/editor",
      "roles/secretmanager.secretAccessor",
      "roles/secretmanager.admin",
    ] # Exemple : plus de permissions en dev
    staging = ["roles/viewer"]
    prod    = ["roles/viewer"] # Permissions plus restrictives en prod
  }
}

variable "developers" {

  type = map(string)
  default = {
    "davidberich@gmail.com" = "david-berichon"
    # "richardberich@gmail.com" = "richard-berichon"
  }
}

data "google_service_account" "production_root_admin_service_account" {
  account_id = "root-admin@${var.project_id}.iam.gserviceaccount.com"
}

locals {
  root_admins_service_accounts = [
    "serviceAccount:${data.google_service_account.production_root_admin_service_account.email}"
  ]
}

locals {
  prod_admins_service_accounts = [
    "serviceAccount:david-berichon-prod@${var.project_id}.iam.gserviceaccount.com"
  ]
  prod_editors_service_accounts = [
    # "serviceAccount:david-berichon-prod@${var.project_id}.iam.gserviceaccount.com"
  ]
}

# After automatic creation of developer service account (from developers list), use the generated service account
# to add the developer as member to get default roles based on his profile.
module "production_members" {
  source      = "./roles"
  project_id  = var.project_id
  admins      = local.prod_admins_service_accounts
  editors     = local.prod_editors_service_accounts
  root_admins = local.root_admins_service_accounts

  admin_user_roles      = var.admin_user_roles
  root_admin_user_roles = var.root_admin_user_roles
  editor_user_roles     = var.admin_user_roles
}

locals {
  staging_admins_service_accounts = concat(local.prod_admins_service_accounts, [
    # "serviceAccount:david-berichon-staging@moov-staging-440506.iam.gserviceaccount.com"
  ])
  staging_editors_service_accounts = concat(local.prod_editors_service_accounts, [
    "serviceAccount:david-berichon-staging@moov-staging-440506.iam.gserviceaccount.com"
  ])
}

# After automatic creation of developer service account (from developers list), use the generated service account
# to add the developer as member to get default roles based on his profile.
module "staging_members" {
  source      = "./roles"
  project_id  = var.staging_project
  admins      = local.staging_admins_service_accounts
  editors     = local.staging_editors_service_accounts
  root_admins = local.root_admins_service_accounts

  admin_user_roles      = var.admin_user_roles
  root_admin_user_roles = var.root_admin_user_roles
  editor_user_roles     = var.admin_user_roles
}

locals {
  dev_admins_service_accounts = concat(local.staging_admins_service_accounts, [
    # "serviceAccount:david-berichon-dev@moov-dev-439608.iam.gserviceaccount.com"
  ])
  dev_editors_service_accounts = concat(local.staging_editors_service_accounts, [
    "serviceAccount:david-berichon-dev@moov-dev-439608.iam.gserviceaccount.com"
  ])
}

# After automatic creation of developer service account (from developers list), use the generated service account
# to add the developer as member to get default roles based on his profile.
module "dev_members" {
  source      = "./roles"
  project_id  = var.dev_project
  admins      = local.dev_admins_service_accounts
  editors     = local.dev_editors_service_accounts
  root_admins = local.root_admins_service_accounts

  admin_user_roles      = var.admin_user_roles
  root_admin_user_roles = var.root_admin_user_roles
  editor_user_roles     = var.admin_user_roles
}

locals {
  environments = {
    "dev"     = var.dev_project,
    "staging" = var.staging_project
    "prod"    = var.project_id
  }
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
      for env, project_id in local.environments : {
        name = "${id}-${env}"
        value = {
          email      = email
          id         = id
          env        = env
          project_id = project_id
          roles      = lookup(var.default_roles_per_environment, env, [])
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

data "google_storage_bucket" "bucket_tf_state_eu_global" {
  name = local.bucket_tf_state_eu_global_name
}

resource "google_storage_bucket_iam_member" "bucket_iam_member" {
  for_each = local.for_each_developer_environment_map
  bucket   = data.google_storage_bucket.bucket_tf_state_eu_global.name
  role     = "roles/storage.objectViewer"
  member   = "serviceAccount:${google_service_account.developer_service_account[each.key].email}"
}

resource "google_storage_bucket_iam_member" "bucket_locking_iam_member" {
  for_each = local.for_each_developer_environment_map
  bucket   = data.google_storage_bucket.bucket_tf_state_eu_global.name
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

# Clés API Google Maps pour chaque développeur
resource "google_apikeys_key" "developer_google_maps_api_key" {
  for_each     = var.developers
  project      = var.dev_project
  name         = "${each.value}-googlemaps-web-api-key"
  display_name = "${each.value} - Web Maps API Key - Dev"
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
  project   = var.dev_project
  secret_id = "${each.value}-googlemaps-web-api-key"
  replication {
    auto {
    }
  }
}

resource "google_secret_manager_secret_version" "developer_maps_api_secret_version" {
  for_each = var.developers
  secret   = google_secret_manager_secret.developer_maps_api_secret[each.key].id
  secret_data_wo = jsonencode({
    apiKey = google_apikeys_key.developer_google_maps_api_key[each.key].key_string
  })
}

# Accès au secret pour chaque compte de service
resource "google_secret_manager_secret_iam_member" "allow_service_account_access" {
  for_each   = local.for_each_developer_environment_map
  project    = var.dev_project
  secret_id  = "${each.value.id}-googlemaps-web-api-key"
  role       = "roles/secretmanager.secretAccessor"
  member     = "serviceAccount:${google_service_account.developer_service_account[each.key].email}"
  depends_on = [google_secret_manager_secret.developer_maps_api_secret]
}
