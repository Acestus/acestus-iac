# Acestus Event Grid Topic Module Outputs

output "resource_id" {
  description = "The resource ID of the Event Grid Topic"
  value       = module.event_grid_topic.resource_id
}

output "name" {
  description = "The name of the Event Grid Topic"
  value       = module.event_grid_topic.name
}

output "endpoint" {
  description = "The endpoint URL of the Event Grid Topic"
  value       = module.event_grid_topic.resource.endpoint
}

output "primary_access_key" {
  description = "The primary access key for the Event Grid Topic"
  value       = module.event_grid_topic.resource.primary_access_key
  sensitive   = true
}

output "resource" {
  description = "The full Event Grid Topic resource object"
  value       = module.event_grid_topic.resource
}
