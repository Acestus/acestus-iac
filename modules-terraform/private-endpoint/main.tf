# Acestus Private Endpoint Module - AVM Wrapper
# Wraps Azure Verified Module: Azure/avm-res-network-privateendpoint/azurerm

module "private_endpoint" {
  source  = "Azure/avm-res-network-privateendpoint/azurerm"
  version = "~> 0.2"

  name                = var.name
  resource_group_name = var.resource_group_name
  location            = var.location

  # Network configuration
  subnet_resource_id = var.subnet_id

  # Private service connection
  private_connection_resource_id = var.private_connection_resource_id
  subresource_names              = var.subresource_names
  is_manual_connection           = var.is_manual_connection

  # Custom network interface name
  custom_network_interface_name = var.custom_network_interface_name

  # Private DNS zone group
  private_dns_zone_group = var.private_dns_zone_group

  # Role assignments
  role_assignments = var.role_assignments

  # Tags
  tags = var.tags
}
