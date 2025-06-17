
module "hosting" {
  source       = "./hosting"
  project_id   = data.google_project.project.project_id
  domain       = var.hosting_domain
  public_dir   = var.hosting_public_dir
  legal_sites  = var.hosting_legal_sites
  site_id      = var.hosting_site_id
  environment  = var.environment
  project_name = var.project_name
}
