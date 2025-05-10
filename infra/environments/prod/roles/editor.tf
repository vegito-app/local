
variable "editors" {
  description = "ID list of environement (prod/staging/dev) editors"
  type        = list(string)
}

variable "editor_user_roles" {
  type = map(string)
}

resource "google_project_iam_member" "editor_user_roles" {
  for_each = {
    for pair in setproduct(keys(var.editor_user_roles), var.editors) :
    "${pair[0]}-${pair[1]}" => {
      role   = var.editor_user_roles[pair[0]]
      member = pair[1]
    }
  }

  project = var.project_id
  role    = each.value.role
  member  = each.value.member
}
