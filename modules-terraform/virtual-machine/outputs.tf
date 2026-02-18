# Acestus Virtual Machine Module Outputs

output "resource_id" {
  description = "The resource ID of the virtual machine"
  value       = module.virtual_machine.resource_id
}

output "name" {
  description = "The name of the virtual machine"
  value       = module.virtual_machine.name
}

output "private_ip_address" {
  description = "The private IP address of the VM"
  value       = module.virtual_machine.network_interfaces
}

output "system_assigned_mi_principal_id" {
  description = "The principal ID of the system assigned managed identity"
  value       = module.virtual_machine.system_assigned_mi_principal_id
}

output "resource" {
  description = "The full virtual machine resource object"
  value       = module.virtual_machine.resource
}
