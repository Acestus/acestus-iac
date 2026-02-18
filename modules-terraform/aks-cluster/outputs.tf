# Acestus AKS Cluster Module Outputs

output "resource_id" {
  description = "The resource ID of the AKS cluster"
  value       = module.aks.resource_id
}

output "name" {
  description = "The name of the AKS cluster"
  value       = module.aks.name
}

output "fqdn" {
  description = "The FQDN of the AKS cluster"
  value       = module.aks.fqdn
}

output "private_fqdn" {
  description = "The private FQDN of the AKS cluster"
  value       = module.aks.private_fqdn
}

output "oidc_issuer_url" {
  description = "The OIDC issuer URL"
  value       = module.aks.oidc_issuer_url
}

output "kubelet_identity" {
  description = "The kubelet identity"
  value       = module.aks.kubelet_identity
}

output "resource" {
  description = "The full AKS cluster resource object"
  value       = module.aks.resource
}
