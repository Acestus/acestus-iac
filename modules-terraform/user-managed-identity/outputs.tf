# Acestus User Managed Identity Module Outputs

output "resource_id" {
  description = "The resource ID of the User Assigned Managed Identity"
  value       = module.user_assigned_identity.resource_id
}

output "name" {
  description = "The name of the User Assigned Managed Identity"
  value       = module.user_assigned_identity.name
}

output "principal_id" {
  description = "The principal ID of the User Assigned Managed Identity"
  value       = module.user_assigned_identity.principal_id
}

output "client_id" {
  description = "The client ID of the User Assigned Managed Identity"
  value       = module.user_assigned_identity.client_id
}

output "tenant_id" {
  description = "The tenant ID of the User Assigned Managed Identity"
  value       = module.user_assigned_identity.tenant_id
}

output "resource" {
  description = "The full User Assigned Managed Identity resource object"
  value       = module.user_assigned_identity.resource
}
