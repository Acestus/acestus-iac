# Acestus Application Insights Module - AVM Wrapper
# Wraps Azure Verified Module: Azure/avm-res-insights-component/azurerm

module "application_insights" {
  source  = "Azure/avm-res-insights-component/azurerm"
  version = "~> 0.2"

  name                = var.name
  resource_group_name = var.resource_group_name
  location            = var.location

  # Application type
  application_type = var.application_type

  # Workspace-based (required for Acestus standards)
  workspace_id = var.workspace_id

  # Retention
  retention_in_days = var.retention_in_days

  # Data cap settings
  daily_data_cap_in_gb                  = var.daily_data_cap_in_gb > 0 ? var.daily_data_cap_in_gb : null
  daily_data_cap_notifications_disabled = var.daily_data_cap_notifications_disabled

  # Sampling
  sampling_percentage = var.sampling_percentage

  # Security settings (Acestus standards)
  disable_ip_masking            = var.disable_ip_masking
  local_authentication_disabled = var.local_authentication_disabled
  internet_ingestion_enabled    = var.internet_ingestion_enabled
  internet_query_enabled        = var.internet_query_enabled

  # Role assignments
  role_assignments = var.role_assignments

  # Diagnostic settings
  diagnostic_settings = var.diagnostic_settings

  # Tags
  tags = var.tags
}
