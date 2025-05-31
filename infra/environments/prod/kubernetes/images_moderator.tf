
resource "kubernetes_deployment" "images_moderator" {
  metadata {
    name = "images-moderator"
    labels = {
      app = "images-moderator"
    }
  }
  spec {
    replicas = 1
    selector {
      match_labels = {
        app = "images-moderator"
      }
    }
    template {
      metadata {
        labels = {
          app = "images-moderator"
        }
      }
      spec {
        container {
          name  = "moderator"
          image = var.input_images_moderator_image
          env {
            name  = "GCP_PROJECT_ID"
            value = var.project_id
          }
          env {
            name  = "APPLICATION_IMAGES_MODERATOR_PUBSUB_TOPIC_INPUT"
            value = var.vegetable_image_created_moderator_pubsub_topic_input
          }
          env {
            name  = "APPLICATION_IMAGES_MODERATOR_PUBSUB_SUBSCRIPTION"
            value = var.vegetable_image_created_moderator_pull_pubsub_subscription
          }
          env {
            name  = "APPLICATION_IMAGES_MODERATOR_PUBSUB_TOPIC_OUTPUT"
            value = var.vegetable_image_validated_moderator_pubsub_topic_output
          }
          env {
            name  = "APPLICATION_IMAGES_MODERATOR_VALIDATED_OUTPUT_CDN_BUCKET"
            value = var.validated_output_bucket
          }
          env {
            name  = "APPLICATION_IMAGES_MODERATOR_CREATED_INPUT_FIREBASESTORAGE_BUCKET"
            value = var.created_images_input_bucket_name
          }
        }
        service_account_name = kubernetes_service_account.input_images_workers.metadata[0].name
      }
    }
  }
}
