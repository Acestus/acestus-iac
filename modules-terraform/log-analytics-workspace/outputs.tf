# Acestus Log Analytics Workspace Module Outputs

output "resource_id" {
  description = "The resource ID of the Log Analytics Workspace"
  value       = module.log_analytics_workspace.resource_id
}

output "name" {
  description = "The name of the Log Analytics Workspace"
  value       = module.log_analytics_workspace.name
}

output "workspace_id" {
  description = "The Workspace ID (GUID) of the Log Analytics Workspace"
  value       = module.log_analytics_workspace.resource.workspace_id
}

output "primary_shared_key" {
  description = "The primary shared key of the Log Analytics Workspace"
  value       = module.log_analytics_workspace.resource.primary_shared_key
  sensitive   = true
}

output "resource" {
  description = "The full Log Analytics Workspace resource object"
  value       = module.log_analytics_workspace.resource
}
