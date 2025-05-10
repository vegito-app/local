resource "google_storage_bucket" "public_images" {
  name     = "${var.project_id}-${var.region}-public-images-web" # Every bucket name must be globally unique
  location = "US"
}

variable "public_web_background_image_filename" {
  description = "public web background image filename"
  type        = string
  default     = "public-web-background-image.jpg"
}

resource "google_storage_bucket_object" "public_web_background_image" {
  name         = var.public_web_background_image_filename
  bucket       = google_storage_bucket.public_images.name
  source       = "${path.module}/${var.public_web_background_image_filename}"
  content_type = "image/jpeg"
}

resource "google_storage_bucket_iam_member" "web_public_image" {
  bucket = google_storage_bucket.public_images.name
  role   = "roles/storage.objectViewer"
  member = "allUsers"
}

resource "google_compute_backend_bucket" "public_cdn" {
  name        = "${var.project_id}-${var.region}-public-cdn" # Every bucket name must be globally unique
  bucket_name = google_storage_bucket.public_images.name
  enable_cdn  = true
}

resource "google_compute_url_map" "url_map" {
  name            = "${var.project_id}-${var.region}-public-cdn-url-map"
  description     = "a description"
  default_service = google_compute_backend_bucket.public_cdn.self_link

  host_rule {
    hosts        = ["*"]
    path_matcher = "allpaths"
  }

  path_matcher {
    name            = "allpaths"
    default_service = google_compute_backend_bucket.public_cdn.self_link
  }
}

resource "google_compute_target_http_proxy" "public_cdn" {
  name    = "${var.project_id}-${var.region}-public-cdn-http-proxy"
  url_map = google_compute_url_map.url_map.self_link
}

resource "google_compute_global_address" "public_cdn" {
  name       = "global-app-address"
  ip_version = "IPV4"
}

resource "google_compute_global_forwarding_rule" "public_cdn" {
  name       = "${var.project_id}-${var.region}-public-cdn-forwarding-rule"
  target     = google_compute_target_http_proxy.public_cdn.self_link
  ip_address = google_compute_global_address.public_cdn.address
  port_range = "80"
}

output "web_background_image_cdn_url" {
  value       = "http://${google_compute_global_address.public_cdn.address}/${google_storage_bucket_object.public_web_background_image.name}"
  description = "CDN URL of the web background image"
}
