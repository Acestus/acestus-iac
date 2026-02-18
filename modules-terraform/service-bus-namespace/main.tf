# Acestus Service Bus Namespace Module - AVM Wrapper
# Wraps Azure Verified Module: Azure/avm-res-servicebus-namespace/azurerm

module "service_bus_namespace" {
  source  = "Azure/avm-res-servicebus-namespace/azurerm"
  version = "~> 0.4"

  name                = var.name
  resource_group_name = var.resource_group_name
  location            = var.location

  # SKU configuration
  sku = var.sku

  # Premium-specific settings
  capacity                     = var.sku == "Premium" ? var.capacity : null
  premium_messaging_partitions = var.sku == "Premium" ? var.premium_messaging_partitions : null
  zone_redundant               = var.sku == "Premium" ? var.zone_redundant : null

  # Security settings (Acestus standards)
  public_network_access_enabled = var.public_network_access_enabled
  minimum_tls_version           = var.minimum_tls_version
  local_auth_enabled            = var.local_auth_enabled

  # Managed identities
  managed_identities = var.managed_identities

  # Network rules
  network_rule_set = var.network_rule_set

  # Queues and topics
  queues = var.queues
  topics = var.topics

  # Role assignments
  role_assignments = var.role_assignments

  # Diagnostic settings
  diagnostic_settings = var.diagnostic_settings

  # Private endpoints
  private_endpoints = var.private_endpoints

  # Tags
  tags = var.tags
}
