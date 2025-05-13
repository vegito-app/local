

# Configures the provider to use the resource block's specified project for quota checks.
provider "google-beta" {
  alias                 = "no_user_project_override"
  user_project_override = true
}
