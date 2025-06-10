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

variable "input_images_moderator_image" {
  description = "Input images moderator Docker image"
  type        = string
}

variable "input_images_cleaner_image" {
  description = "Input images cleaner Docker image"
  type        = string
}

variable "created_images_input_bucket_name" {
  description = "The name of the bucket where created input images will be stored."
  type        = string
}

variable "validated_output_bucket" {
  description = "The name of the bucket where validated images will be stored."
  type        = string
}

variable "vegetable_image_created_moderator_pubsub_topic_input" {
  description = "The Pub/Sub topic for input messages."
  type        = string
}

variable "vegetable_image_created_moderator_pull_pubsub_subscription" {
  description = "The Pub/Sub subscription for input messages."
  type        = string
}

variable "vegetable_image_validated_moderator_pubsub_topic_output" {
  description = "The Pub/Sub topic for output messages."
  type        = string
}

variable "input_images_moderator_sa_email" {
  description = "The email of the service account used by the input images workers."
  type        = string
}

variable "input_images_cleaner_sa_email" {
  description = "The email of the service account used by the input images cleaner."
  type        = string
}
