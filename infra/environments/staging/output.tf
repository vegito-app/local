output "docker_repository" {
  description = "Project docker container registry."
  value       = module.gcloud.docker_repository
}

output "public_docker_repository" {
  description = "Project public docker container registry."
  value       = module.gcloud.public_docker_repository
}

output "github_actions_private_key" {
  value     = module.gcloud.github_actions_private_key
  sensitive = true
}

output "firebase_ios_config_plist" {
  value       = module.gcloud.firebase_ios_config_plist
  description = "Configuration client Firebase iOS (GoogleService-Info.plist)"
  sensitive   = true
}

output "firebase_android_config_json" {
  value       = module.gcloud.firebase_android_config_json
  description = "Configuration client Firebase Android (google-services.json)"
  sensitive   = true
}
output "backend_url" {
  value       = module.application.backend_url
  description = "URL of the backend service"
}

output "oauth_redirect_uri" {
  description = "Web OAUTH redirect URI (must authorized set on google console 'ID clients OAuth 2.0' credentials)"
  value       = module.gcloud.oauth_redirect_uri
}

output "web_background_image_cdn_url" {
  value       = module.cdn.web_background_image_cdn_url
  description = "CDN URL of the web background image"
}

output "application_backend_cloud_run_sa_email" {
  value       = module.application.application_backend_cloud_run_sa_email
  description = "Application - Backend - Service Account - Email"
}
