resource "kubernetes_service_account" "input_images_cleaner" {
  metadata {
    name      = "input-images-cleaner"
    namespace = "default"
    annotations = {
      "iam.gke.io/gcp-service-account" = var.input_images_cleaner_sa_email
    }
  }
}


resource "kubernetes_cron_job_v1" "images_cleaner" {
  metadata {
    name = "images-cleaner"
    labels = {
      app = "images-cleaner"
    }
  }
  spec {
    schedule = "0 2 * * *"
    job_template {
      metadata {
        labels = {
          app = "images-cleaner"
        }
      }
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
                value = var.created_images_input_bucket_name
              }
            }
            restart_policy       = "OnFailure"
            service_account_name = kubernetes_service_account.input_images_cleaner.metadata[0].name
          }
        }
      }
    }
  }
}
