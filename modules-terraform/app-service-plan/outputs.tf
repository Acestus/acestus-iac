# Acestus App Service Plan Module Outputs

output "resource_id" {
  description = "The resource ID of the App Service Plan"
  value       = module.app_service_plan.resource_id
}

output "name" {
  description = "The name of the App Service Plan"
  value       = module.app_service_plan.name
}

output "resource" {
  description = "The full App Service Plan resource object"
  value       = module.app_service_plan.resource
}
