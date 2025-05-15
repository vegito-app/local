admin_user_roles = [

  "roles/artifactregistry.admin",

  "roles/cloudfunctions.admin",

  "roles/container.clusterAdmin",
  "roles/container.admin",

  "roles/firebasedatabase.viewer",

  "roles/resourcemanager.projectIamAdmin",
  "roles/iam.serviceAccountAdmin",
  "roles/iam.serviceAccountTokenCreator",
  "roles/iam.serviceAccountUser",

  "roles/compute.instanceAdmin.v1",

  "roles/identitytoolkit.admin",

  "roles/serviceusage.apiKeysAdmin",
  "roles/serviceusage.apiKeysViewer",
  "roles/serviceusage.serviceUsageConsumer",

  "roles/storage.admin",
]

editor_user_roles = [

  "roles/artifactregistry.writer",
  "roles/datastore.viewer",
  "roles/editor",
  "roles/secretmanager.secretAccessor",
  "roles/storage.objectViewer",
]

root_admin_user_roles = [

  "roles/iam.roleAdmin",
  "roles/iam.serviceAccountTokenCreator",
  "roles/iam.serviceAccountKeyAdmin",

  "roles/cloudkms.admin",
  "roles/secretmanager.admin",

  "roles/datastore.owner",
  "roles/firebasedatabase.admin",

  "roles/artifactregistry.reader",
]

default_roles_per_environment = {
  dev = [
    "roles/editor",
    "roles/secretmanager.secretAccessor",
    "roles/secretmanager.admin",
  ],
  staging = [
    "roles/viewer",
  ],
  prod    = [
    "roles/viewer",
  ],
}