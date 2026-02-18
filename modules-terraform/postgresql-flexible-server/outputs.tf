# Acestus PostgreSQL Flexible Server Module Outputs

output "resource_id" {
  description = "The resource ID of the PostgreSQL Flexible Server"
  value       = module.postgresql_flexible_server.resource_id
}

output "name" {
  description = "The name of the PostgreSQL Flexible Server"
  value       = module.postgresql_flexible_server.name
}

output "fqdn" {
  description = "The FQDN of the PostgreSQL Flexible Server"
  value       = module.postgresql_flexible_server.resource.fqdn
}

output "resource" {
  description = "The full PostgreSQL Flexible Server resource object"
  value       = module.postgresql_flexible_server.resource
}
