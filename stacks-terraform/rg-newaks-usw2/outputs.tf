# AKS Stack - Outputs

# ============================================================================
# Resource Group
# ============================================================================

output "resource_group_name" {
  description = "The name of the resource group"
  value       = azurerm_resource_group.main.name
}

output "resource_group_id" {
  description = "The ID of the resource group"
  value       = azurerm_resource_group.main.id
}

# ============================================================================
# AKS Cluster
# ============================================================================

output "aks_cluster_name" {
  description = "The name of the AKS cluster"
  value       = module.aks_stack.aks_name
}

output "aks_cluster_resource_id" {
  description = "The resource ID of the AKS cluster"
  value       = module.aks_stack.aks_resource_id
}

output "aks_cluster_fqdn" {
  description = "The FQDN of the AKS cluster"
  value       = module.aks_stack.aks_fqdn
}

output "aks_oidc_issuer_url" {
  description = "The OIDC issuer URL for workload identity"
  value       = module.aks_stack.aks_oidc_issuer_url
}

output "aks_identity_principal_id" {
  description = "The principal ID of the AKS managed identity"
  value       = module.aks_stack.aks_identity_principal_id
}

# ============================================================================
# Container Registry
# ============================================================================

output "container_registry_name" {
  description = "The name of the Container Registry"
  value       = module.aks_stack.acr_name
}

output "container_registry_login_server" {
  description = "The login server of the Container Registry"
  value       = module.aks_stack.acr_login_server
}

# ============================================================================
# Key Vault
# ============================================================================

output "key_vault_name" {
  description = "The name of the Key Vault"
  value       = module.aks_stack.key_vault_name
}

output "key_vault_uri" {
  description = "The URI of the Key Vault"
  value       = module.aks_stack.key_vault_uri
}
