output "public_cdn_address" {
  value       = "http://${google_compute_global_address.public_cdn.address}"
  description = "Public images CDN address"
}
output "web_background_image_cdn_url" {
  value       = "http://${google_compute_global_address.public_cdn.address}/${google_storage_bucket_object.public_web_background_image.name}"
  description = "CDN URL of the web background image"
}
output "public_images_bucket_name" {
  value       = google_storage_bucket.public_images.name
  description = "The name of the public images bucket."
}
