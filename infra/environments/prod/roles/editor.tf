variable "editor_user_roles" {
  type = map(string)
  default = {
    "artifactregistry_writer" : "roles/artifactregistry.writer",
    "datastore_viewer" : "roles/datastore.viewer",
    "global_editor" : "roles/editor",
    "secret_accessor" : "roles/secretmanager.secretAccessor",
    "storage_objectviewer" : "roles/storage.objectViewer",
  }
}

resource "google_project_iam_binding" "editor_user_roles" {
  for_each = var.editor_user_roles
  project  = var.project_id
  role     = each.value
  members  = var.editors
}
