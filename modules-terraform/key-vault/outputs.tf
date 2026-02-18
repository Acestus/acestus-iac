# Acestus Key Vault Module Outputs

output "resource_id" {
  description = "The resource ID of the Key Vault"
  value       = module.keyvault.resource_id
}

output "name" {
  description = "The name of the Key Vault"
  value       = module.keyvault.name
}

output "vault_uri" {
  description = "The URI of the Key Vault"
  value       = module.keyvault.uri
}

output "resource" {
  description = "The full Key Vault resource object"
  value       = module.keyvault.resource
}
