# Acestus Route Table Module - AVM Wrapper
# Wraps Azure Verified Module: Azure/avm-res-network-routetable/azurerm

module "route_table" {
  source  = "Azure/avm-res-network-routetable/azurerm"
  version = "~> 0.5"

  name                = var.name
  resource_group_name = var.resource_group_name
  location            = var.location

  # BGP route propagation (disable for hub-spoke scenarios)
  disable_bgp_route_propagation = var.disable_bgp_route_propagation

  # Routes
  routes = var.routes

  # Role assignments
  role_assignments = var.role_assignments

  # Tags
  tags = var.tags
}
