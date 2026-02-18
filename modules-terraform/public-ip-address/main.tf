# Acestus Public IP Address Module - AVM Wrapper
# Wraps Azure Verified Module: Azure/avm-res-network-publicipaddress/azurerm

module "public_ip_address" {
  source  = "Azure/avm-res-network-publicipaddress/azurerm"
  version = "~> 0.2"

  name                = var.name
  resource_group_name = var.resource_group_name
  location            = var.location

  # SKU configuration (Acestus security default: Standard)
  sku      = var.sku
  sku_tier = var.sku_tier

  # IP configuration
  allocation_method = var.allocation_method
  ip_version        = var.ip_version
  zones             = var.zones

  # DNS settings
  domain_name_label = var.domain_name_label
  reverse_fqdn      = var.reverse_fqdn

  # Timeout settings
  idle_timeout_in_minutes = var.idle_timeout_in_minutes

  # DDoS protection (Acestus security)
  ddos_protection_mode = var.ddos_protection_mode

  # Role assignments
  role_assignments = var.role_assignments

  # Diagnostic settings
  diagnostic_settings = var.diagnostic_settings

  # Tags
  tags = var.tags
}
