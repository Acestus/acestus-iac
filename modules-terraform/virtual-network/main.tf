# Acestus Virtual Network Module - AVM Wrapper
# Wraps Azure Verified Module: Azure/avm-res-network-virtualnetwork/azurerm

module "virtual_network" {
  source  = "Azure/avm-res-network-virtualnetwork/azurerm"
  version = "~> 0.17"

  name                = var.name
  resource_group_name = var.resource_group_name
  location            = var.location

  # Address space
  address_space = var.address_space

  # DNS servers
  dns_servers = var.dns_servers

  # Subnets
  subnets = var.subnets

  # DDoS protection
  ddos_protection_plan = var.ddos_protection_plan

  # Peerings
  peerings = var.peerings

  # Role assignments
  role_assignments = var.role_assignments

  # Diagnostic settings
  diagnostic_settings = var.diagnostic_settings

  # Tags
  tags = var.tags
}
