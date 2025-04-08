variable "project_id" {
  description = "GCP project ID"
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

