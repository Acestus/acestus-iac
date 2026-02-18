# Acestus Network Security Group Module Outputs

output "resource_id" {
  description = "The resource ID of the network security group"
  value       = module.network_security_group.resource_id
}

output "name" {
  description = "The name of the network security group"
  value       = module.network_security_group.name
}

output "resource" {
  description = "The full network security group resource object"
  value       = module.network_security_group.resource
}
