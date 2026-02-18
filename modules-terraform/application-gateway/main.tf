# Acestus Application Gateway Module - AVM Wrapper
# Wraps Azure Verified Module: Azure/avm-res-network-applicationgateway/azurerm

module "application_gateway" {
  source  = "Azure/avm-res-network-applicationgateway/azurerm"
  version = "~> 0.5"

  name                = var.name
  resource_group_name = var.resource_group_name
  location            = var.location

  # SKU configuration (Acestus security default: WAF_v2)
  sku = {
    name     = var.sku_name
    tier     = var.sku_tier
    capacity = var.capacity
  }

  # Availability zones
  zones = var.zones

  # Gateway IP configuration
  gateway_ip_configuration = var.gateway_ip_configuration

  # Frontend configuration
  frontend_ip_configuration = var.frontend_ip_configuration
  frontend_ports            = var.frontend_ports

  # Backend configuration
  backend_address_pools = var.backend_address_pools
  backend_http_settings = var.backend_http_settings

  # Listener and routing configuration
  http_listeners        = var.http_listeners
  request_routing_rules = var.request_routing_rules

  # WAF configuration (Acestus security - enabled by default)
  waf_configuration = var.waf_configuration

  # SSL configuration
  ssl_certificates = var.ssl_certificates
  ssl_policy       = var.ssl_policy

  # Managed identities
  managed_identities = var.managed_identities

  # Role assignments
  role_assignments = var.role_assignments

  # Diagnostic settings
  diagnostic_settings = var.diagnostic_settings

  # Tags
  tags = var.tags
}
