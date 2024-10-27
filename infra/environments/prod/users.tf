resource "google_service_account_iam_member" "user_service_account_binding" {
  service_account_id = "${data.google_project.project.id}/serviceAccounts/root-admin@${data.google_project.project.project_id}.iam.gserviceaccount.com"
  role               = "roles/iam.serviceAccountUser"
  member             = "user:davidberich@gmail.com"
}
