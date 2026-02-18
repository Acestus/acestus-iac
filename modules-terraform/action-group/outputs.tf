# Acestus Action Group Module Outputs

output "resource_id" {
  description = "The resource ID of the Action Group"
  value       = azurerm_monitor_action_group.this.id
}

output "name" {
  description = "The name of the Action Group"
  value       = azurerm_monitor_action_group.this.name
}
