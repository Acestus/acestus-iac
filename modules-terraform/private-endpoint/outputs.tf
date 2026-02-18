# Acestus Private Endpoint Module Outputs

output "resource_id" {
  description = "The resource ID of the private endpoint"
  value       = module.private_endpoint.resource_id
}

output "name" {
  description = "The name of the private endpoint"
  value       = module.private_endpoint.name
}

output "private_ip_address" {
  description = "The private IP address of the private endpoint"
  value       = try(module.private_endpoint.resource.private_service_connection[0].private_ip_address, null)
}

output "resource" {
  description = "The full private endpoint resource object"
  value       = module.private_endpoint.resource
}
