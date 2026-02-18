# Acestus Virtual Machine Module Variables

variable "name" {
  type        = string
  description = "The name of the virtual machine"
}

variable "resource_group_name" {
  type        = string
  description = "The name of the resource group"
}

variable "location" {
  type        = string
  description = "The Azure region for the virtual machine"
}

variable "sku_size" {
  type        = string
  description = "The VM size SKU"
  default     = "Standard_D2s_v5"
}

variable "zone" {
  type        = string
  description = "The availability zone for the VM"
  default     = null
}

variable "os_type" {
  type        = string
  description = "The OS type (Linux or Windows)"
  default     = "Linux"
}

variable "admin_username" {
  type        = string
  description = "The admin username"
}

variable "admin_password" {
  type        = string
  description = "The admin password (for Windows or if SSH not used)"
  default     = null
  sensitive   = true
}

variable "disable_password_authentication" {
  type        = bool
  description = "Disable password authentication for Linux VMs"
  default     = true
}

variable "admin_ssh_keys" {
  type = list(object({
    public_key = string
    username   = optional(string)
  }))
  description = "SSH public keys for Linux VMs"
  default     = []
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
    storage_account_type = "Premium_LRS"
    disk_size_gb         = 128
  }
}

variable "data_disk_managed_disks" {
  type        = map(any)
  description = "Data disk configurations"
  default     = {}
}

variable "network_interfaces" {
  type        = map(any)
  description = "Network interface configurations"
}

variable "boot_diagnostics" {
  type        = bool
  description = "Enable boot diagnostics"
  default     = true
}

variable "boot_diagnostics_storage_account_uri" {
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
  description = "VM extensions"
  default     = {}
}

variable "encryption_at_host_enabled" {
  type        = bool
  description = "Enable encryption at host"
  default     = true
}

variable "role_assignments" {
  type        = map(any)
  description = "Role assignments for the VM"
  default     = {}
}

variable "tags" {
  type        = map(string)
  description = "Tags to apply to the virtual machine"
  default     = {}
}
