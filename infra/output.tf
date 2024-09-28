
output "backend" {
  value       = module.infra.backend
  description = "web application uri"
}

output "web_background_image_cdn_url" {
  value       = module.infra.web_background_image_cdn_url
  description = "CDN URL of the web background image"
}

output "docker_repository" {
  description = "Project docker container registry."
  value       = module.infra.docker_repository
}

output "docker_repository_public" {
  description = "Project public docker container registry."
  value       = module.infra.docker_repository_public
}

output "github_actions_private_key" {
  value     = module.infra.github_actions_private_key
  sensitive = true
}
