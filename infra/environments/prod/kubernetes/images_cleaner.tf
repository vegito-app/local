resource "kubernetes_cron_job" "images_cleaner" {
  metadata {
    name = "images-cleaner"
    labels = {
      app = "images-cleaner"
    }
  }
  spec {
    schedule = "0 2 * * *"
    job_template {
      spec {
        template {
          metadata {
            labels = {
              app = "images-cleaner"
            }
          }
          spec {
            container {
              name  = "image-cleaner"
              image = var.input_images_cleaner_image
              env {
                name  = "CLEANER_BUCKET_NAME"
                value = data.google_storage_bucket.firebase_storage_bucket.name
              }
            }
            restart_policy       = "OnFailure"
            service_account_name = kubernetes_service_account.input_images_workers.metadata[0].name
          }
        }
      }
    }
  }
}
