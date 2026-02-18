# Acestus Container Registry Module - AVM Wrapper
# Wraps Azure Verified Module: Azure/avm-res-containerregistry-registry/azurerm

module "container_registry" {
  source  = "Azure/avm-res-containerregistry-registry/azurerm"
  version = "~> 0.5"

  name                = var.name
  resource_group_name = var.resource_group_name
  location            = var.location

  # SKU
  sku = var.sku

  # Admin user
  admin_enabled = var.admin_enabled

  # Network access
  public_network_access_enabled = var.public_network_access_enabled
  network_rule_bypass_option    = var.network_rule_bypass_option

  # Network rules
  network_rule_set = var.network_rule_set

  # Zone redundancy
  zone_redundancy_enabled = var.zone_redundancy_enabled

  # Anonymous pull
  anonymous_pull_enabled = var.anonymous_pull_enabled

  # Data endpoint
  data_endpoint_enabled = var.data_endpoint_enabled

  # Retention policy
  retention_policy_in_days = var.retention_policy_in_days
  retention_policy_enabled = var.retention_policy_enabled

  # Encryption
  encryption = var.encryption

  # Identity
  managed_identities = var.managed_identities

  # Role assignments
  role_assignments = var.role_assignments

  # Diagnostic settings
  diagnostic_settings = var.diagnostic_settings

  # Private endpoints
  private_endpoints = var.private_endpoints

  # Tags
  tags = var.tags
}
