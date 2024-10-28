
output "backend_url" {
  value       = module.gcloud.backend_url
  description = "web application uri"
}

output "docker_repository" {
  description = "Project docker container registry."
  value       = module.gcloud.docker_repository
}

output "docker_repository_public" {
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
}

output "firebase_android_config_json" {
  value       = module.gcloud.firebase_android_config_json
  description = "Configuration client Firebase Android (google-services.json)"
}
