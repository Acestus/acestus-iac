# Acestus Application Insights Module Outputs

output "resource_id" {
  description = "The resource ID of the Application Insights component"
  value       = module.application_insights.resource_id
}

output "name" {
  description = "The name of the Application Insights component"
  value       = module.application_insights.name
}

output "instrumentation_key" {
  description = "The instrumentation key for the Application Insights component"
  value       = module.application_insights.resource.instrumentation_key
  sensitive   = true
}

output "connection_string" {
  description = "The connection string for the Application Insights component"
  value       = module.application_insights.resource.connection_string
  sensitive   = true
}

output "resource" {
  description = "The full Application Insights resource object"
  value       = module.application_insights.resource
}
