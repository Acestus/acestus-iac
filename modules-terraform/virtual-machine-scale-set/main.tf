# Acestus Virtual Machine Scale Set Module - AVM Wrapper
# Wraps Azure Verified Module: Azure/avm-res-compute-virtualmachinescaleset/azurerm

module "vmss" {
  source  = "Azure/avm-res-compute-virtualmachinescaleset/azurerm"
  version = "~> 0.9"

  name                = var.name
  resource_group_name = var.resource_group_name
  location            = var.location

  # Capacity
  sku_name  = var.sku_name
  instances = var.instances

  # Zones
  zone_balance = var.zone_balance
  zones        = var.zones

  # Upgrade policy
  upgrade_mode                        = var.upgrade_mode
  automatic_os_upgrade_policy_enabled = var.automatic_os_upgrade_policy_enabled
  rolling_upgrade_policy              = var.rolling_upgrade_policy

  # OS configuration
  os_profile = var.os_profile

  # Source image
  source_image_reference = var.source_image_reference

  # OS disk
  os_disk = var.os_disk

  # Data disks
  data_disk = var.data_disk

  # Network interfaces
  network_interface = var.network_interface

  # Boot diagnostics
  boot_diagnostics             = var.boot_diagnostics
  boot_diagnostics_storage_uri = var.boot_diagnostics_storage_uri

  # Identity
  managed_identities = var.managed_identities

  # Extensions
  extensions = var.extensions

  # Encryption at host
  encryption_at_host_enabled = var.encryption_at_host_enabled

  # Scale-in policy
  scale_in = var.scale_in

  # Overprovision
  overprovision = var.overprovision

  # Single placement group
  single_placement_group = var.single_placement_group

  # Role assignments
  role_assignments = var.role_assignments

  # Tags
  tags = var.tags
}
