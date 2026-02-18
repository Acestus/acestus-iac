# Acestus Virtual Machine Module - AVM Wrapper
# Wraps Azure Verified Module: Azure/avm-res-compute-virtualmachine/azurerm

module "virtual_machine" {
  source  = "Azure/avm-res-compute-virtualmachine/azurerm"
  version = "~> 0.20"

  name                = var.name
  resource_group_name = var.resource_group_name
  location            = var.location

  # VM size
  sku_size = var.sku_size
  zone     = var.zone

  # OS configuration
  os_type                         = var.os_type
  admin_username                  = var.admin_username
  admin_password                  = var.admin_password
  disable_password_authentication = var.disable_password_authentication
  admin_ssh_keys                  = var.admin_ssh_keys

  # Image reference
  source_image_reference = var.source_image_reference

  # OS disk
  os_disk = var.os_disk

  # Data disks
  data_disk_managed_disks = var.data_disk_managed_disks

  # Network interfaces
  network_interfaces = var.network_interfaces

  # Boot diagnostics
  boot_diagnostics                     = var.boot_diagnostics
  boot_diagnostics_storage_account_uri = var.boot_diagnostics_storage_account_uri

  # Identity
  managed_identities = var.managed_identities

  # Extensions
  extensions = var.extensions

  # Encryption at host
  encryption_at_host_enabled = var.encryption_at_host_enabled

  # Role assignments
  role_assignments = var.role_assignments

  # Tags
  tags = var.tags
}
