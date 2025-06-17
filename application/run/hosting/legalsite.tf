resource "google_firebase_hosting_site" "this" {
  provider = google-beta
  project  = var.project_id
  site_id  = "vegito-app-legal-site-${var.project_name}-hosting"
}

resource "google_firebase_hosting_version" "this" {
  provider = google-beta
  site_id  = google_firebase_hosting_site.this.site_id
}

# resource "google_firebase_hosting_version_file" "files" {
#   provider = google-beta
#   for_each = {
#     for pair in flatten([
#       for lang, files in var.legal_sites : [
#         for page, path in files : {
#           key  = "${lang}/${page}"
#           file = path
#         }
#       ]
#       ]) : pair.key => {
#       file_path = "/${pair.file}"
#       source    = "${var.public_dir}/${pair.file}"
#     }
#   }

#   version_name = google_firebase_hosting_version.this.name
#   file_path    = each.value.file_path
#   source {
#     files_count = 1
#     filesize    = file(each.value.source)
#     sha256_hash = filesha256(each.value.source)
#   }
# }

resource "google_firebase_hosting_release" "release" {
  provider     = google-beta
  site_id      = google_firebase_hosting_site.this.site_id
  version_name = google_firebase_hosting_version.this.name
  message      = "Initial deployment"
}

resource "google_firebase_hosting_custom_domain" "custom_domain" {
  provider      = google-beta
  project       = var.project_id
  site_id       = google_firebase_hosting_site.this.site_id
  custom_domain = var.domain
}
