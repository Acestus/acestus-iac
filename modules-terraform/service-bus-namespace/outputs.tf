# Acestus Service Bus Namespace Module Outputs

output "resource_id" {
  description = "The resource ID of the Service Bus Namespace"
  value       = module.service_bus_namespace.resource_id
}

output "name" {
  description = "The name of the Service Bus Namespace"
  value       = module.service_bus_namespace.name
}

output "default_primary_connection_string" {
  description = "The primary connection string of the Service Bus Namespace"
  value       = try(module.service_bus_namespace.resource.default_primary_connection_string, null)
  sensitive   = true
}

output "resource" {
  description = "The full Service Bus Namespace resource object"
  value       = module.service_bus_namespace.resource
}
