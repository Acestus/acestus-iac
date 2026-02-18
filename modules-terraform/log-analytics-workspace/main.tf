# Acestus Log Analytics Workspace Module - AVM Wrapper
# Wraps Azure Verified Module: Azure/avm-res-operationalinsights-workspace/azurerm

module "log_analytics_workspace" {
  source  = "Azure/avm-res-operationalinsights-workspace/azurerm"
  version = "~> 0.5"

  name                = var.name
  resource_group_name = var.resource_group_name
  location            = var.location

  # SKU and capacity
  log_analytics_workspace_sku                                = var.sku
  log_analytics_workspace_retention_in_days                  = var.retention_in_days
  log_analytics_workspace_daily_quota_gb                     = var.daily_quota_gb > 0 ? var.daily_quota_gb : null
  log_analytics_workspace_reservation_capacity_in_gb_per_day = var.reservation_capacity_in_gb_per_day

  # Network settings
  log_analytics_workspace_internet_ingestion_enabled = var.internet_ingestion_enabled
  log_analytics_workspace_internet_query_enabled     = var.internet_query_enabled

  # Security settings (Acestus standards)
  log_analytics_workspace_local_authentication_disabled   = var.local_authentication_disabled
  log_analytics_workspace_allow_resource_only_permissions = var.allow_resource_only_permissions
  log_analytics_workspace_cmk_for_query_forced            = var.cmk_for_query_forced

  # Role assignments
  role_assignments = var.role_assignments

  # Diagnostic settings
  diagnostic_settings = var.diagnostic_settings

  # Tags
  tags = var.tags
}
