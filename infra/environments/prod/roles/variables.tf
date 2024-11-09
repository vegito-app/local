variable "project_id" {
  description = "GCP project ID"
  type        = string
}
variable "editors" {
  description = "ID list of environement (prod/staging/dev) editors"
  type        = list(string)
}
variable "admins" {
  description = "ID list of environement (prod/staging/dev) administrators"
  type        = list(string)
}
