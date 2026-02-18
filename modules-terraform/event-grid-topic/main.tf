# Acestus Event Grid Topic Module - AVM Wrapper
# Wraps Azure Verified Module: Azure/avm-res-eventgrid-topic/azurerm

module "event_grid_topic" {
  source  = "Azure/avm-res-eventgrid-topic/azurerm"
  version = "~> 0.1"

  name                = var.name
  resource_group_name = var.resource_group_name
  location            = var.location

  # Schema configuration
  input_schema = var.input_schema

  # Security settings (Acestus standards)
  public_network_access_enabled = var.public_network_access_enabled
  local_auth_enabled            = var.local_auth_enabled

  # Inbound IP rules
  inbound_ip_rules = var.inbound_ip_rules

  # Managed identities
  managed_identities = var.managed_identities

  # Role assignments
  role_assignments = var.role_assignments

  # Private endpoints
  private_endpoints = var.private_endpoints

  # Diagnostic settings
  diagnostic_settings = var.diagnostic_settings

  # Tags
  tags = var.tags
}
