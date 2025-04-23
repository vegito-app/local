output "vault_tf_apply_service_account_email" {
  description = "Email of the GCP service account used by the Vault Terraform apply job"
  value       = data.google_service_account.vault_tf_apply.email
}

output "vault_policy_backend_application_name" {
  description = "The name of the Vault policy applied to application backends"
  value       = vault_policy.backend_application.name
}

output "vault_role_vault_tf_apply" {
  description = "Name of the Vault GCP role bound to the vault_tf_apply job"
  value       = vault_gcp_auth_backend_role.vault_tf_apply.role
}

output "vault_role_application_backend" {
  description = "Name of the Vault GCP role bound to the backend application"
  value       = vault_gcp_auth_backend_role.application_backend.role
}
