# Acestus AKS AZD Pattern Module Outputs

# ============================================================================
# AKS Cluster Outputs
# ============================================================================

output "aks_name" {
  description = "The name of the AKS cluster"
  value       = module.aks.name
}

output "aks_resource_id" {
  description = "The resource ID of the AKS cluster"
  value       = module.aks.resource_id
}

output "aks_fqdn" {
  description = "The FQDN of the AKS cluster"
  value       = module.aks.fqdn
}

output "aks_private_fqdn" {
  description = "The private FQDN of the AKS cluster (if private cluster)"
  value       = module.aks.private_fqdn
}

output "aks_oidc_issuer_url" {
  description = "The OIDC issuer URL"
  value       = module.aks.oidc_issuer_url
}

output "aks_kubelet_identity" {
  description = "The kubelet managed identity"
  value       = module.aks.kubelet_identity
}

output "aks_identity_principal_id" {
  description = "The principal ID of the AKS managed identity"
  value       = module.aks.resource.identity[0].principal_id
}

# ============================================================================
# Container Registry Outputs
# ============================================================================

output "acr_name" {
  description = "The name of the Container Registry"
  value       = module.acr.name
}

output "acr_resource_id" {
  description = "The resource ID of the Container Registry"
  value       = module.acr.resource_id
}

output "acr_login_server" {
  description = "The login server of the Container Registry"
  value       = module.acr.resource.login_server
}

# ============================================================================
# Key Vault Outputs
# ============================================================================

output "key_vault_name" {
  description = "The name of the Key Vault"
  value       = module.key_vault.name
}

output "key_vault_resource_id" {
  description = "The resource ID of the Key Vault"
  value       = module.key_vault.resource_id
}

output "key_vault_uri" {
  description = "The URI of the Key Vault"
  value       = module.key_vault.resource.vault_uri
}

# ============================================================================
# Resource Group
# ============================================================================

output "resource_group_name" {
  description = "The name of the resource group"
  value       = var.resource_group_name
}

output "location" {
  description = "The Azure region"
  value       = var.location
}
