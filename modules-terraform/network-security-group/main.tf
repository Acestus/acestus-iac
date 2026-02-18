# Acestus Network Security Group Module - AVM Wrapper
# Wraps Azure Verified Module: Azure/avm-res-network-networksecuritygroup/azurerm

module "network_security_group" {
  source  = "Azure/avm-res-network-networksecuritygroup/azurerm"
  version = "~> 0.5"

  name                = var.name
  resource_group_name = var.resource_group_name
  location            = var.location

  # Security rules
  security_rules = var.security_rules

  # Role assignments
  role_assignments = var.role_assignments

  # Diagnostic settings
  diagnostic_settings = var.diagnostic_settings

  # Tags
  tags = var.tags
}
