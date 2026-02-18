# Acestus Route Table Module Outputs

output "resource_id" {
  description = "The resource ID of the route table"
  value       = module.route_table.resource_id
}

output "name" {
  description = "The name of the route table"
  value       = module.route_table.name
}

output "subnets" {
  description = "The list of subnets associated with the route table"
  value       = module.route_table.resource.subnets
}

output "resource" {
  description = "The full route table resource object"
  value       = module.route_table.resource
}
