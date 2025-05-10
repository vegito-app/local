variable "root_admins" {
  description = "ID list of environement (prod/staging/dev) root administrators"
  type        = list(string)
}

variable "root_admin_user_roles" {
  type = map(string)
}

resource "google_project_iam_member" "root_admin_user_roles" {
  for_each = {
    for pair in setproduct(keys(var.root_admin_user_roles), var.root_admins) :
    "${pair[0]}-${pair[1]}" => {
      role   = var.root_admin_user_roles[pair[0]]
      member = pair[1]
    }
  }

  project = var.project_id
  role    = each.value.role
  member  = each.value.member
}
