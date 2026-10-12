
output "database_username" {
  value = local_file.example.id
}


output "greetings_local_settings" {
  description = "All local settings used to generate the greeting application properties file"
  value       = module.greeting.local_settings
}
