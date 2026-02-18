# Acestus Load Balancer Module Outputs

output "resource_id" {
  description = "The resource ID of the load balancer"
  value       = module.load_balancer.resource_id
}

output "name" {
  description = "The name of the load balancer"
  value       = module.load_balancer.name
}

output "frontend_ip_configurations" {
  description = "The frontend IP configurations of the load balancer"
  value       = module.load_balancer.resource.frontend_ip_configuration
}

output "backend_address_pool_ids" {
  description = "Map of backend address pool names to their resource IDs"
  value       = module.load_balancer.backend_address_pool_ids
}

output "resource" {
  description = "The full load balancer resource object"
  value       = module.load_balancer.resource
}
