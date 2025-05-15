admin_user_roles = {

  "artifactregistry_admin" = "roles/artifactregistry.admin",

  "cloudfunction_admin" = "roles/cloudfunctions.admin",

  "container_cluster_admin" = "roles/container.clusterAdmin",
  "container_cluster_admin" = "roles/container.admin",

  "firebasedatabase_viewer" = "roles/firebasedatabase.viewer",

  "iam_admin"                         = "roles/resourcemanager.projectIamAdmin",
  "iam_service_account_admin"         = "roles/iam.serviceAccountAdmin",
  "iam_service_account_token_creator" = "roles/iam.serviceAccountTokenCreator",
  "iam_service_account_user_as_admin" = "roles/iam.serviceAccountUser",

  "compute_instance_admin" = "roles/compute.instanceAdmin.v1",

  "identitytoolkit_admin" = "roles/identitytoolkit.admin",

  "serviceusage_apikeys_admin"  = "roles/serviceusage.apiKeysAdmin",
  "serviceusage_apikeys_viewer" = "roles/serviceusage.apiKeysViewer",
  "servuceusage_consumer"       = "roles/serviceusage.serviceUsageConsumer",

  "storage_admin" = "roles/storage.admin",
}

editor_user_roles = {

  "artifactregistry_writer" = "roles/artifactregistry.writer",
  "datastore_viewer"        = "roles/datastore.viewer",
  "global_editor"           = "roles/editor",
  "secret_accessor"         = "roles/secretmanager.secretAccessor",
  "storage_objectviewer"    = "roles/storage.objectViewer",
}

root_admin_user_roles = {

  "iam_roles_admin"                   = "roles/iam.roleAdmin",
  "iam_service_account_token_creator" = "roles/iam.serviceAccountTokenCreator",
  "iam_service_account_key_admin"     = "roles/iam.serviceAccountKeyAdmin",

  "secret_cloud_kms_admin" = "roles/cloudkms.admin",
  "secret_admin"           = "roles/secretmanager.admin",

  "datastore_owner"        = "roles/datastore.owner",
  "firebasedatabase_admin" = "roles/firebasedatabase.admin",

  "legacy_1" = "roles/artifactregistry.reader",
}
