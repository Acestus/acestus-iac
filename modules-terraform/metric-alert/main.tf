# Acestus Metric Alert Module - Native Terraform
# Uses azurerm_monitor_metric_alert resource directly (no AVM available)

resource "azurerm_monitor_metric_alert" "this" {
  name                = var.name
  resource_group_name = var.resource_group_name
  scopes              = var.scopes
  description         = var.description
  severity            = var.severity
  enabled             = var.enabled
  frequency           = var.frequency
  window_size         = var.window_size
  auto_mitigate       = var.auto_mitigate

  criteria {
    metric_namespace       = var.criteria.metric_namespace
    metric_name            = var.criteria.metric_name
    aggregation            = var.criteria.aggregation
    operator               = var.criteria.operator
    threshold              = var.criteria.threshold
    skip_metric_validation = var.criteria.skip_metric_validation

    dynamic "dimension" {
      for_each = var.criteria.dimensions
      content {
        name     = dimension.value.name
        operator = dimension.value.operator
        values   = dimension.value.values
      }
    }
  }

  dynamic "action" {
    for_each = var.action
    content {
      action_group_id    = action.value.action_group_id
      webhook_properties = action.value.webhook_properties
    }
  }

  tags = var.tags
}
