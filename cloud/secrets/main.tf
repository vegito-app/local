resource "google_identity_platform_default_supported_idp_config" "google" {
  count         = var.create_secret ? 1 : 0
  enabled       = true
  idp_id        = "google.com"
  client_id     = "402960374845-lu67bhh9fe2hsdfk2ci3r5j6js7acsvn.apps.googleusercontent.com"
  client_secret = var.google_cloud_idp_google_web_auth_secret
}
