# Acestus Application Gateway Module Outputs

output "resource_id" {
  description = "The resource ID of the application gateway"
  value       = module.application_gateway.resource_id
}

output "name" {
  description = "The name of the application gateway"
  value       = module.application_gateway.name
}

output "frontend_ip_configuration" {
  description = "The frontend IP configuration of the application gateway"
  value       = module.application_gateway.resource.frontend_ip_configuration
}

output "resource" {
  description = "The full application gateway resource object"
  value       = module.application_gateway.resource
}
