variable "vm_users" {
  type = map(string)
}

variable "developer_vm_machine_type" {
  type    = string
  default = "c3-standard-8"
}

data "google_service_account" "developer_service_account" {
  for_each   = var.vm_users
  account_id = "${each.value}-dev"
}

variable "dev_vm_disk_type" {
  type    = string
  default = "pd-balanced"
}

locals {
  dev_vm_zone = "${var.region}-c"
}

resource "google_compute_disk" "dev_vm_disk" {
  for_each = var.vm_users
  name     = "${each.value}-${var.dev_vm_disk_type}"
  type     = var.dev_vm_disk_type
  zone     = local.dev_vm_zone
  image    = "projects/ubuntu-os-cloud/global/images/family/ubuntu-2204-lts"
  size     = 100
}

resource "google_compute_instance" "dev_vm" {
  for_each = {
    for email, user in var.vm_users : user => email
  }
  name         = "${each.key}-developer-vm-${var.developer_vm_machine_type}"
  machine_type = var.developer_vm_machine_type
  advanced_machine_features {
    enable_nested_virtualization = true
  }
  min_cpu_platform = "Intel Sapphire Rapids" # pour c3
  zone             = local.dev_vm_zone
  scheduling {
    preemptible        = false
    automatic_restart  = true
    provisioning_model = "STANDARD"
  }
  boot_disk {
    source      = google_compute_disk.dev_vm_disk[each.value].self_link
    auto_delete = false
  }

  service_account {
    email  = data.google_service_account.developer_service_account[each.value].email
    scopes = ["cloud-platform"]
  }

  metadata = {
    enable-vmx = "TRUE"
  }

  metadata_startup_script = <<-EOT
    #!/bin/bash
    set -euxo pipefail

    apt-get update
    apt-get install -y \
      ca-certificates \
      curl \
      gnupg \
      lsb-release \
      git \
      make \
      htop \
      iftop

    mkdir -p /etc/apt/keyrings
    curl -fsSL https://download.docker.com/linux/ubuntu/gpg | gpg --dearmor -o /etc/apt/keyrings/docker.gpg
    echo \
      "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.gpg] https://download.docker.com/linux/ubuntu \
      $(lsb_release -cs) stable" > /etc/apt/sources.list.d/docker.list

    apt-get update
    apt-get install -y docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin

    apt-get install -y cpu-checker qemu-kvm libvirt-daemon-system libvirt-clients bridge-utils virtinst virt-manager
    kvm-ok || true
    groupadd -f kvm
    usermod -aG kvm dev

    usermod -aG docker dev

    mkdir -p /workspaces
    chmod o+rw /workspaces
    
    echo '#!/bin/bash
    if who | grep -q "pts/"; then exit 0; fi
    gcloud compute instances suspend $(hostname) --zone=europe-west1-b' > /usr/local/bin/suspend-if-idle.sh
    chmod +x /usr/local/bin/suspend-if-idle.sh

    echo "*/30 * * * * root /usr/local/bin/suspend-if-idle.sh" >> /etc/crontab
    
    cat << 'EOF' > /etc/profile.d/00-aliases.sh
    alias h='htop'
    alias i='sudo iftop'
    alias ll='ls -lha'
    alias l='ls -lh'
    alias la='ls -Ah'
    alias lla='ls -lhA'
    EOF
    chmod +x /etc/profile.d/00-aliases.sh

  EOT

  network_interface {
    network = "default"
    access_config {} # external IP
  }

  labels = {
    env  = "dev"
    user = each.key
  }

  tags = ["dev-ssh", "dev-ssh-${each.key}"]
}
output "dev_vm_ips" {
  value = {
    for email, user in var.vm_users :
    user => google_compute_instance.dev_vm[user].network_interface[0].access_config[0].nat_ip
  }
}
resource "google_project_iam_member" "ssh_access_using_user_email" {
  for_each = var.vm_users
  project  = data.google_project.project.project_id
  role     = "roles/compute.osLogin"
  member   = "user:${each.key}"
}
