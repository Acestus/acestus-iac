# Acestus Private DNS Zone Module Outputs

output "resource_id" {
  description = "The resource ID of the private DNS zone"
  value       = module.private_dns_zone.resource_id
}

output "name" {
  description = "The name of the private DNS zone"
  value       = module.private_dns_zone.resource.name
}

output "resource" {
  description = "The full private DNS zone resource object"
  value       = module.private_dns_zone.resource
}
