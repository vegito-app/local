
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

variable "users_email" {

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
  production_admins_service_accounts = [
    "serviceAccount:david-berichon-prod@${var.project_id}.iam.gserviceaccount.com"
  ]
  production_editors_service_accounts = [
    # "serviceAccount:david-berichon-prod@${var.project_id}.iam.gserviceaccount.com"
  ]
}

module "prod_users" {
  source      = "../../users"
  project_id  = var.project_id
  users_email = var.users_email
  environment = "prod"
}

module "production_admin_members" {
  source     = "../../roles"
  project_id = var.project_id
  users_sa   = local.production_admins_service_accounts

  roles = var.admin_user_roles
}

module "production_editor_members" {
  source     = "../../roles"
  project_id = var.project_id
  users_sa   = local.production_editors_service_accounts

  roles = var.editor_user_roles
}

module "production_root_admin_members" {
  source     = "../../roles"
  project_id = var.project_id
  users_sa   = local.root_admins_service_accounts

  roles = var.root_admin_user_roles
}

locals {
  staging_admins_service_accounts = concat(local.production_admins_service_accounts, [
    # "serviceAccount:david-berichon-staging@moov-staging-440506.iam.gserviceaccount.com"
  ])
  staging_editors_service_accounts = concat(local.production_editors_service_accounts, [
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
  source     = "../../roles"
  project_id = var.staging_project
  users_sa   = local.staging_admins_service_accounts

  roles = var.staging_admin_user_roles
}

module "staging_editor_members" {
  source     = "../../roles"
  project_id = var.staging_project
  users_sa   = local.staging_editors_service_accounts

  roles = var.staging_editor_user_roles
}

module "staging_root_admin_members" {
  source     = "../../roles"
  project_id = var.staging_project
  users_sa   = local.root_admins_service_accounts

  roles = var.staging_root_admin_user_roles
}


module "dev_users" {
  source      = "../../users"
  project_id  = var.dev_project
  users_email = var.users_email
  environment = "dev"
}

locals {
  dev_admins_service_accounts = concat(local.staging_admins_service_accounts, [
    # "serviceAccount:david-berichon-dev@moov-dev-439608.iam.gserviceaccount.com"
  ])
  dev_editors_service_accounts = concat(local.staging_editors_service_accounts, [
    "serviceAccount:david-berichon-dev@moov-dev-439608.iam.gserviceaccount.com"
  ])
}

module "dev_admin_members" {
  source     = "../../roles"
  project_id = var.dev_project
  users_sa   = local.dev_admins_service_accounts

  roles = var.dev_admin_user_roles
}

module "dev_editor_members" {
  source     = "../../roles"
  project_id = var.dev_project
  users_sa   = local.dev_editors_service_accounts

  roles = var.dev_editor_user_roles
}

module "dev_root_admin_members" {
  source     = "../../roles"
  project_id = var.dev_project
  users_sa   = local.root_admins_service_accounts

  roles = var.dev_root_admin_user_roles
}

resource "google_project_iam_custom_role" "k8s_rbac_role" {
  role_id     = "k8sRBACAdmin"
  project     = var.project_id
  title       = "Kubernetes RBAC Admin Role"
  description = "Role for managing Kubernetes RBAC resources in GKE"
  permissions = [
    "container.clusterRoles.create",
    "container.clusterRoleBindings.create",
    "container.roles.create",
    "container.roleBindings.create"
  ]
}

resource "google_project_iam_member" "prod_k8s_rbac_admin_user_roles" {
  for_each = toset(local.production_admins_service_accounts)
  project  = var.project_id
  role     = google_project_iam_custom_role.k8s_rbac_role.name
  member   = each.value
}



data "google_storage_bucket" "bucket_tf_state_eu_global" {
  name = local.bucket_tf_state_eu_global_name
}

# Clés API Google Maps pour chaque développeur
resource "google_apikeys_key" "user_google_maps_api_key" {
  for_each     = var.users_email
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
resource "google_secret_manager_secret" "user_maps_api_secret" {
  for_each  = var.users_email
  project   = var.dev_project
  secret_id = "${each.value}-googlemaps-web-api-key"
  replication {
    auto {
    }
  }
}

resource "google_secret_manager_secret_version" "user_maps_api_secret_version" {
  for_each = var.users_email
  secret   = google_secret_manager_secret.user_maps_api_secret[each.key].id
  secret_data_wo = jsonencode({
    apiKey = google_apikeys_key.user_google_maps_api_key[each.key].key_string
  })
}

data "google_service_account" "dev_user_service_account" {
  project    = var.dev_project
  for_each   = var.users_email
  account_id = "${each.value}-dev"
}

resource "google_secret_manager_secret_iam_member" "allow_service_account_access" {
  for_each  = var.users_email
  project   = var.dev_project
  secret_id = "${each.value}-googlemaps-web-api-key"
  role      = "roles/secretmanager.secretAccessor"
  # member     = "serviceAccount:${google_service_account.user_service_account[each.key].email}"
  member     = "serviceAccount:${data.google_service_account.dev_user_service_account[each.key].email}"
  depends_on = [google_secret_manager_secret.user_maps_api_secret]
}

data "google_service_account" "prod_user_service_account" {
  for_each   = var.users_email
  account_id = "${each.value}-prod"
}

resource "google_storage_bucket_iam_member" "bucket_iam_member" {
  for_each = var.users_email
  bucket   = data.google_storage_bucket.bucket_tf_state_eu_global.name
  role     = "roles/storage.objectViewer"
  member   = "serviceAccount:${data.google_service_account.prod_user_service_account[each.key].email}"
}

resource "google_storage_bucket_iam_member" "bucket_locking_iam_member" {
  for_each = var.users_email
  bucket   = data.google_storage_bucket.bucket_tf_state_eu_global.name
  role     = "roles/storage.objectAdmin"
  member   = "serviceAccount:${data.google_service_account.prod_user_service_account[each.key].email}"
}

# resource "google_project_iam_member" "artifact_registry_reader" {
#   for_each = var.users_email
#   project  = var.project_id
#   role     = "roles/artifactregistry.reader"
#   member   = "serviceAccount:${google_service_account.user_service_account[each.key].email}"
# }

