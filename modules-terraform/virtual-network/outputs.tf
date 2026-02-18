# Acestus Virtual Network Module Outputs

output "resource_id" {
  description = "The resource ID of the virtual network"
  value       = module.virtual_network.resource_id
}

output "name" {
  description = "The name of the virtual network"
  value       = module.virtual_network.name
}

output "subnets" {
  description = "The subnets in the virtual network"
  value       = module.virtual_network.subnets
}

output "resource" {
  description = "The full virtual network resource object"
  value       = module.virtual_network.resource
}
