# Acestus Storage Account Module Outputs

output "resource_id" {
  description = "The resource ID of the storage account"
  value       = module.storage_account.resource_id
}

output "name" {
  description = "The name of the storage account"
  value       = module.storage_account.name
}

output "primary_blob_endpoint" {
  description = "The primary blob endpoint"
  value       = module.storage_account.resource.primary_blob_endpoint
}

output "primary_connection_string" {
  description = "The primary connection string"
  value       = module.storage_account.resource.primary_connection_string
  sensitive   = true
}

output "resource" {
  description = "The full storage account resource object"
  value       = module.storage_account.resource
}
