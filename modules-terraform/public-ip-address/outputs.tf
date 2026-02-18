# Acestus Public IP Address Module Outputs

output "resource_id" {
  description = "The resource ID of the public IP address"
  value       = module.public_ip_address.resource_id
}

output "name" {
  description = "The name of the public IP address"
  value       = module.public_ip_address.name
}

output "ip_address" {
  description = "The public IP address"
  value       = module.public_ip_address.resource.ip_address
}

output "fqdn" {
  description = "The fully qualified domain name of the public IP address"
  value       = module.public_ip_address.resource.fqdn
}

output "resource" {
  description = "The full public IP address resource object"
  value       = module.public_ip_address.resource
}
