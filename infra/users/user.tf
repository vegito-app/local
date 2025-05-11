resource "google_service_account" "user_service_account" {
  for_each     = var.users_email
  account_id   = "${each.value}-${var.environment}"
  display_name = "${var.environment} service account for ${each.key}"
  project      = var.project_id
}

# Attribuez le rôle de gestionnaire de clé à ce compte de service spécifique
resource "google_service_account_iam_member" "key_admin" {
  for_each = var.users_email

  service_account_id = google_service_account.user_service_account[each.key].name

  role   = "roles/iam.serviceAccountKeyAdmin"
  member = "user:${each.key}"
}

