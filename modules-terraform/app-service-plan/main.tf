# Acestus App Service Plan Module - AVM Wrapper
# Wraps Azure Verified Module: Azure/avm-res-web-serverfarm/azurerm

module "app_service_plan" {
  source  = "Azure/avm-res-web-serverfarm/azurerm"
  version = "~> 2.0"

  name                = var.name
  resource_group_name = var.resource_group_name
  location            = var.location

  # OS type
  os_type = var.os_type

  # SKU configuration
  sku_name = var.sku_name

  # Scaling settings
  maximum_elastic_worker_count = var.maximum_elastic_worker_count
  worker_count                 = var.worker_count
  per_site_scaling_enabled     = var.per_site_scaling_enabled
  zone_balancing_enabled       = var.zone_balancing_enabled

  # Role assignments
  role_assignments = var.role_assignments

  # Diagnostic settings
  diagnostic_settings = var.diagnostic_settings

  # Tags
  tags = var.tags
}
