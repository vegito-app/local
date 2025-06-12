output "firebase_ios_config_plist" {
  value       = base64decode(data.google_firebase_apple_app_config.ios_config.config_file_contents)
  description = "Configuration client Firebase iOS (GoogleService-Info.plist)"
}
output "firebase_android_config_json" {
  value       = base64decode(data.google_firebase_android_app_config.android_config.config_file_contents)
  description = "Configuration client Firebase Android (google-services.json)"
}
output "application_backend_cloud_run_sa_email" {
  value       = google_service_account.application_backend_cloud_run_sa.email
  description = "Application - Backend - Service Account - Email"
}
output "private_docker_repository_name" {
  value       = google_artifact_registry_repository.private_docker_repository.name
  description = "Private Docker Repository Name"
}
