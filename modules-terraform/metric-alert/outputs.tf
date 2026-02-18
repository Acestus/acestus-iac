# Acestus Metric Alert Module Outputs

output "resource_id" {
  description = "The resource ID of the Metric Alert"
  value       = azurerm_monitor_metric_alert.this.id
}

output "name" {
  description = "The name of the Metric Alert"
  value       = azurerm_monitor_metric_alert.this.name
}
