variable "environment" {
  description = "Environment name (dev, staging, prod)"
  type        = string
}
variable "create_secret" {
  description = "Create secrets if true"
  type        = bool
  default     = false
}
