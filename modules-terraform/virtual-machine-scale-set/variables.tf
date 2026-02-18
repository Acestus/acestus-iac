# Acestus Virtual Machine Scale Set Module Variables

variable "name" {
  type        = string
  description = "The name of the virtual machine scale set"
}

variable "resource_group_name" {
  type        = string
  description = "The name of the resource group"
}

variable "location" {
  type        = string
  description = "The Azure region for the VMSS"
}

variable "sku_name" {
  type        = string
  description = "The VM size SKU"
  default     = "Standard_D2s_v5"
}

variable "instances" {
  type        = number
  description = "Initial instance count"
  default     = 2
}

variable "zone_balance" {
  type        = bool
  description = "Balance instances across zones"
  default     = true
}

variable "zones" {
  type        = list(string)
  description = "Availability zones for the VMSS"
  default     = ["1", "2", "3"]
}

variable "upgrade_mode" {
  type        = string
  description = "Upgrade policy mode"
  default     = "Rolling"
}

variable "automatic_os_upgrade_policy_enabled" {
  type        = bool
  description = "Enable automatic OS upgrades"
  default     = true
}

variable "rolling_upgrade_policy" {
  type        = any
  description = "Rolling upgrade policy configuration"
  default = {
    max_batch_instance_percent              = 20
    max_unhealthy_instance_percent          = 20
    max_unhealthy_upgraded_instance_percent = 20
    pause_time_between_batches              = "PT0S"
  }
}

variable "os_profile" {
  type        = any
  description = "OS profile configuration"
}

variable "source_image_reference" {
  type = object({
    publisher = string
    offer     = string
    sku       = string
    version   = string
  })
  description = "The source image reference"
  default = {
    publisher = "Canonical"
    offer     = "0001-com-ubuntu-server-jammy"
    sku       = "22_04-lts-gen2"
    version   = "latest"
  }
}

variable "os_disk" {
  type        = any
  description = "OS disk configuration"
  default = {
    caching              = "ReadWrite"
    storage_account_type = "Premium_ZRS"
    disk_size_gb         = 128
  }
}

variable "data_disk" {
  type        = list(any)
  description = "Data disk configurations"
  default     = []
}

variable "network_interface" {
  type        = list(any)
  description = "Network interface configurations"
}

variable "boot_diagnostics" {
  type        = bool
  description = "Enable boot diagnostics"
  default     = true
}

variable "boot_diagnostics_storage_uri" {
  type        = string
  description = "Storage account URI for boot diagnostics"
  default     = null
}

variable "managed_identities" {
  type        = any
  description = "Managed identity configuration"
  default     = null
}

variable "extensions" {
  type        = map(any)
  description = "VMSS extensions"
  default     = {}
}

variable "encryption_at_host_enabled" {
  type        = bool
  description = "Enable encryption at host"
  default     = true
}

variable "scale_in" {
  type        = any
  description = "Scale-in policy configuration"
  default = {
    rule                   = "Default"
    force_deletion_enabled = false
  }
}

variable "overprovision" {
  type        = bool
  description = "Enable overprovisioning"
  default     = false
}

variable "single_placement_group" {
  type        = bool
  description = "Enable single placement group"
  default     = false
}

variable "role_assignments" {
  type        = map(any)
  description = "Role assignments for the VMSS"
  default     = {}
}

variable "tags" {
  type        = map(string)
  description = "Tags to apply to the VMSS"
  default     = {}
}
