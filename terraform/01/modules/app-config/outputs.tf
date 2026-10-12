
output "app_config_file" {
  description = "The path to the generated application properties file"
  value       = local_file.properties.filename
}

output "app_config_content" {
  description = "The content of the generated application properties file"
  value       = local_file.properties.content
}

output "local_settings" {
  description = "All local settings used to generate the application properties file"
  value       = local.settings
}
