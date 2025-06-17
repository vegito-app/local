output "firebase_hosting_site_id" {
  value = google_firebase_hosting_site.this.site_id
}
output "firebase_hosting_custom_domain" {
  value = google_firebase_hosting_custom_domain.custom_domain.custom_domain
}
