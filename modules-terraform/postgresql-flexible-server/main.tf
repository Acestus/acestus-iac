# Acestus PostgreSQL Flexible Server Module - AVM Wrapper
# Wraps Azure Verified Module: Azure/avm-res-dbforpostgresql-flexibleserver/azurerm

module "postgresql_flexible_server" {
  source  = "Azure/avm-res-dbforpostgresql-flexibleserver/azurerm"
  version = "~> 0.2"

  name                = var.name
  resource_group_name = var.resource_group_name
  location            = var.location

  # SKU and version
  sku_name = var.sku_name
  version  = var.postgresql_version

  # Storage configuration
  storage_mb   = var.storage_mb
  storage_tier = var.storage_tier

  # Backup configuration
  backup_retention_days        = var.backup_retention_days
  geo_redundant_backup_enabled = var.geo_redundant_backup_enabled

  # Creation mode
  create_mode = var.create_mode

  # Authentication (Acestus standard - prefer AAD)
  administrator_login    = var.authentication.password_auth_enabled ? var.administrator_login : null
  administrator_password = var.authentication.password_auth_enabled ? var.administrator_password : null
  authentication         = var.authentication

  # Network configuration (Acestus standard - private access)
  delegated_subnet_id           = var.delegated_subnet_id
  private_dns_zone_id           = var.private_dns_zone_id
  public_network_access_enabled = var.public_network_access_enabled

  # High availability
  high_availability = var.high_availability

  # Maintenance window
  maintenance_window = var.maintenance_window

  # Availability zone
  zone = var.zone

  # Databases
  databases = var.databases

  # Server configurations
  server_configurations = var.server_configurations

  # Firewall rules
  firewall_rules = var.firewall_rules

  # Managed identities
  managed_identities = var.managed_identities

  # Role assignments
  role_assignments = var.role_assignments

  # Diagnostic settings
  diagnostic_settings = var.diagnostic_settings

  # Tags
  tags = var.tags
}
