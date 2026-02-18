# Acestus Load Balancer Module - AVM Wrapper
# Wraps Azure Verified Module: Azure/avm-res-network-loadbalancer/azurerm

module "load_balancer" {
  source  = "Azure/avm-res-network-loadbalancer/azurerm"
  version = "~> 0.5"

  name                = var.name
  resource_group_name = var.resource_group_name
  location            = var.location

  # SKU configuration (Acestus security default: Standard)
  sku      = var.sku
  sku_tier = var.sku_tier

  # Frontend IP configurations
  frontend_ip_configurations = var.frontend_ip_configurations

  # Backend address pools
  backend_address_pools = var.backend_address_pools

  # Health probes
  lb_probes = var.health_probes

  # Load balancer rules
  lb_rules = var.lb_rules

  # NAT rules
  lb_nat_rules = var.nat_rules

  # Outbound rules
  lb_outbound_rules = var.outbound_rules

  # Role assignments
  role_assignments = var.role_assignments

  # Diagnostic settings
  diagnostic_settings = var.diagnostic_settings

  # Tags
  tags = var.tags
}
