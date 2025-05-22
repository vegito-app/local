vm_users = {
  "davidberich@gmail.com" = {
    "id"           = "david-berichon",
    "machine_type" = "c3-standard-8",
    "disk_type"    = "pd-balanced",
    "disk_size"    = 100,
    "zone"         = "europe-west1-c",
  }
}

vm_machine_type_architecture = {
  "n2-standard-16" = {
    "cpu_platform" = "Intel Cascade Lake",
  },
  "c3-standard-8" = {
    "cpu_platform" = "Intel Sapphire Rapids",
  },
}
