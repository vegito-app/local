variable "project_id" {
  description = "GCP project ID"
  type        = string
}
variable "project_number" {
  description = "GCP project number"
  type        = string
}
variable "region" {
  description = "GCP used region"
  type        = string
}
variable "vault_version" {
  description = "GCP used region"
  type        = string
  default     = "1.19.0"
}
variable "helm_vault_chart_version" {
  description = "GCP used region"
  type        = string
  default     = "0.30.0"
}
variable "vault_gcp_credentials_secret_name" {
  default     = "vault-gcp-credentials"
  description = "kubernetes secrets contains vault GCP credentials"
}
variable "vault_tf_apply_member_sa_list" {
  description = "ID list of environement (prod/staging/dev) editors service accounts"
  type        = list(string)
}

