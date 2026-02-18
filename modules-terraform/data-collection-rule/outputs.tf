# Acestus Data Collection Rule Module Outputs

output "resource_id" {
  description = "The resource ID of the Data Collection Rule"
  value       = azurerm_monitor_data_collection_rule.this.id
}

output "name" {
  description = "The name of the Data Collection Rule"
  value       = azurerm_monitor_data_collection_rule.this.name
}

output "immutable_id" {
  description = "The immutable ID of the Data Collection Rule"
  value       = azurerm_monitor_data_collection_rule.this.immutable_id
}
