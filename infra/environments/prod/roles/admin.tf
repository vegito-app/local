variable "admin_user_roles" {
  type = map(string)
  default = {
    "apikeys_admin" : "roles/serviceusage.apiKeysAdmin"
    "artifactregistry_admin" : "roles/artifactregistry.admin",
    "cloudfunction_admin" : "roles/cloudfunctions.admin",
    "datastore_owner" : "roles/datastore.owner",
    "firebasedatabase_admin" : "roles/firebasedatabase.admin",
    "firebasedatabase_viewer" : "roles/firebasedatabase.viewer",
    "iam_admin" : "roles/resourcemanager.projectIamAdmin",
    "roles_admin" : "roles/iam.roleAdmin",
    "secret_admin" : "roles/secretmanager.admin",
    "identitytoolkit_admin" : "roles/identitytoolkit.admin",
    "service_account_key_admin" : "roles/iam.serviceAccountKeyAdmin",
    "service_account_user_as_admin" : "roles/iam.serviceAccountUser",
    "serviceusage_apikey_viewer" : "roles/serviceusage.apiKeysViewer",
    "servuceussage_consumer" : "roles/serviceusage.serviceUsageConsumer",
    "storage_admin" : "roles/storage.admin",
  }
}

resource "google_project_iam_binding" "admin_user_roles" {
  for_each = var.admin_user_roles
  project  = var.project_id
  role     = each.value
  members  = var.admins
}
