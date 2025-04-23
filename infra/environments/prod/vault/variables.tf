variable "project_id" {
  description = "GCP project ID"
  type        = string
  default     = "moov-438615"
}
variable "region" {
  description = "GCP used region"
  type        = string
  default     = "europe-west1"
}

variable "vault_addr" {
  description = "Vault address"
  default     = "http://vault-helm.vault.svc.cluster.local:8200"
}

variable "vault_token" {
  description = "Vault token utilisé pour l’auth locale (mode debug)"
  type        = string
  default     = null
}

variable "gcp_creds" {
  description = "Chemin vers le fichier credentials GCP (mode GitOps)"
  type        = string
  default     = null
}

variable "gcp_service_account" {
  description = "Nom du service account GCP utilisé pour auth_login"
  type        = string
  default     = null
}
