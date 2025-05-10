variable "admins" {
  description = "ID list of environement (prod/staging/dev) administrators"
  type        = list(string)
}

variable "admin_user_roles" {
  type = map(string)
}

resource "google_project_iam_member" "admin_user_roles" {
  for_each = {
    for pair in setproduct(keys(var.admin_user_roles), var.admins) :
    "${pair[0]}-${pair[1]}" => {
      role   = var.admin_user_roles[pair[0]]
      member = pair[1]
    }
  }

  project = var.project_id
  role    = each.value.role
  member  = each.value.member
}

resource "google_project_iam_custom_role" "k8s_rbac_role" {
  role_id     = "k8sRBACAdmin"
  project     = var.project_id
  title       = "Kubernetes RBAC Admin Role"
  description = "Role for managing Kubernetes RBAC resources in GKE"
  permissions = [
    "container.clusterRoles.create",
    "container.clusterRoleBindings.create",
    "container.roles.create",
    "container.roleBindings.create"
  ]
}

resource "google_project_iam_member" "k8s_rbac_admin_user_roles" {
  for_each = toset(var.admins)
  project  = var.project_id
  role     = google_project_iam_custom_role.k8s_rbac_role.name
  member   = each.value
}
