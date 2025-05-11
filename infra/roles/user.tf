
resource "google_project_iam_member" "roles" {
  for_each = {
    for pair in setproduct(var.roles, var.users_sa) :
    "${pair[0]}-${pair[1]}" => {
      role   = pair[0]
      member = pair[1]
    }
  }

  project = var.project_id
  role    = each.value.role
  member  = each.value.member
}

variable "user_native_email_roles" {
  type = list(string)
  default = [
    "roles/viewer",
  ]
}

locals {
  flattened_for_each_user_map = flatten([
    for email, id in var.users_sa : [
      {
        id    = id
        email = email
      }
    ]
  ])
  flattened_for_each_user_environment_map = flatten([
    for idx, sa in var.users_sa : {
      idx = "${idx}"
      value = {
        service_account = sa
        roles           = var.user_native_email_roles
      }
    }
  ])
  for_each_user_environment_map = { for item in local.flattened_for_each_user_environment_map : item.idx => item.value }
}

resource "google_project_iam_member" "user_email_roles" {
  for_each = {
    for idx, roles in flatten([
      for key, value in local.for_each_user_environment_map : [
        for role in value.roles : {
          id              = "${key}.${role}"
          role            = role
          service_account = value.service_account
        }
      ]
    ]) : idx => roles
  }
  project = var.project_id
  role    = each.value.role
  member  = each.value.service_account
}
