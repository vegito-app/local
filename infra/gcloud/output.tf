output "firebase_ios_config_plist" {
  value       = base64decode(data.google_firebase_apple_app_config.ios_config.config_file_contents)
  description = "Configuration client Firebase iOS (GoogleService-Info.plist)"
}

output "firebase_android_config_json" {
  value       = base64decode(data.google_firebase_android_app_config.android_config.config_file_contents)
  description = "Configuration client Firebase Android (google-services.json)"
}
