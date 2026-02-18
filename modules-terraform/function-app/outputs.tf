# Acestus Function App Module Outputs

output "resource_id" {
  description = "The resource ID of the Function App"
  value       = module.function_app.resource_id
}

output "name" {
  description = "The name of the Function App"
  value       = module.function_app.name
}

output "default_hostname" {
  description = "The default hostname of the Function App"
  value       = module.function_app.resource.default_hostname
}

output "principal_id" {
  description = "The principal ID of the system-assigned managed identity"
  value       = try(module.function_app.system_assigned_mi_principal_id, null)
}

output "resource" {
  description = "The full Function App resource object"
  value       = module.function_app.resource
}
