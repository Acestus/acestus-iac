# Acestus Virtual Machine Scale Set Module Outputs

output "resource_id" {
  description = "The resource ID of the VMSS"
  value       = module.vmss.resource_id
}

output "name" {
  description = "The name of the VMSS"
  value       = module.vmss.name
}

output "identity" {
  description = "The identity of the VMSS"
  value       = module.vmss.identity
}

output "resource" {
  description = "The full VMSS resource object"
  value       = module.vmss.resource
}
