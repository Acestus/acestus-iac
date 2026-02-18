# Acestus Storage Account Module - AVM Wrapper
# Wraps Azure Verified Module: Azure/avm-res-storage-storageaccount/azurerm

module "storage_account" {
  source  = "Azure/avm-res-storage-storageaccount/azurerm"
  version = "~> 0.6"

  name                = var.name
  resource_group_name = var.resource_group_name
  location            = var.location

  # Account settings
  account_tier             = var.account_tier
  account_replication_type = var.account_replication_type
  account_kind             = var.account_kind
  access_tier              = var.access_tier

  # Security defaults (Acestus standards)
  https_traffic_only_enabled        = var.https_traffic_only_enabled
  min_tls_version                   = var.min_tls_version
  public_network_access_enabled     = var.public_network_access_enabled
  shared_access_key_enabled         = var.shared_access_key_enabled
  infrastructure_encryption_enabled = var.infrastructure_encryption_enabled
  allow_nested_items_to_be_public   = var.allow_nested_items_to_be_public

  # Network rules
  network_rules = var.network_rules

  # Blob properties
  blob_properties = var.blob_properties

  # Containers
  containers = var.containers

  # Role assignments
  role_assignments = var.role_assignments

  # Diagnostic settings
  diagnostic_settings = var.diagnostic_settings

  # Private endpoints
  private_endpoints = var.private_endpoints

  # Managed identity
  managed_identities = var.managed_identities

  # Tags
  tags = var.tags
}
