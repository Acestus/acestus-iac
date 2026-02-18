# Acestus Function App Module - AVM Wrapper
# Wraps Azure Verified Module: Azure/avm-res-web-site/azurerm

module "function_app" {
  source  = "Azure/avm-res-web-site/azurerm"
  version = "~> 0.20"

  name                = var.name
  resource_group_name = var.resource_group_name
  location            = var.location

  # Function App type
  kind = "functionapp"

  # Service plan
  os_type                  = var.os_type
  service_plan_resource_id = var.service_plan_id

  # Storage configuration
  function_app_storage_account_name          = var.storage_account_name
  function_app_storage_account_access_key    = var.storage_uses_managed_identity ? null : var.storage_account_access_key
  function_app_storage_uses_managed_identity = var.storage_uses_managed_identity

  # Functions runtime
  functions_extension_version = var.functions_extension_version

  # Application settings
  app_settings = var.app_settings

  # Connection strings
  connection_strings = var.connection_strings

  # Managed identities (Acestus standard - prefer managed identity)
  managed_identities = var.managed_identities

  # Security settings (Acestus standards)
  https_only                    = var.https_only
  public_network_access_enabled = var.public_network_access_enabled

  # Site config with security defaults
  site_config = merge({
    ftps_state          = var.ftps_state
    minimum_tls_version = var.minimum_tls_version
  }, var.site_config)

  # VNet integration
  virtual_network_subnet_id = var.virtual_network_subnet_id

  # Private endpoints
  private_endpoints = var.private_endpoints

  # Diagnostic settings
  diagnostic_settings = var.diagnostic_settings

  # Role assignments
  role_assignments = var.role_assignments

  # Tags
  tags = var.tags
}
