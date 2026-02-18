# Acestus Container Registry Module Outputs

output "resource_id" {
  description = "The resource ID of the container registry"
  value       = module.container_registry.resource_id
}

output "name" {
  description = "The name of the container registry"
  value       = module.container_registry.name
}

output "login_server" {
  description = "The login server URL"
  value       = module.container_registry.login_server
}

output "admin_username" {
  description = "The admin username (if admin is enabled)"
  value       = module.container_registry.admin_username
  sensitive   = true
}

output "resource" {
  description = "The full container registry resource object"
  value       = module.container_registry.resource
}
