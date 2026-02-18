# Acestus Key Vault Module Variables

variable "name" {
  type        = string
  description = "The name of the Key Vault"
}

variable "resource_group_name" {
  type        = string
  description = "The name of the resource group"
}

variable "location" {
  type        = string
  description = "The Azure region for the Key Vault"
}

variable "tenant_id" {
  type        = string
  description = "The Azure AD tenant ID for the Key Vault"
}

variable "sku_name" {
  type        = string
  description = "The SKU name of the Key Vault"
  default     = "standard"
  validation {
    condition     = contains(["standard", "premium"], var.sku_name)
    error_message = "SKU name must be 'standard' or 'premium'."
  }
}

variable "enabled_for_deployment" {
  type        = bool
  description = "Enable Key Vault for VM deployment"
  default     = false
}

variable "enabled_for_disk_encryption" {
  type        = bool
  description = "Enable Key Vault for disk encryption"
  default     = false
}

variable "enabled_for_template_deployment" {
  type        = bool
  description = "Enable Key Vault for ARM template deployment"
  default     = false
}

variable "enable_rbac_authorization" {
  type        = bool
  description = "Enable RBAC authorization instead of access policies"
  default     = true
}

variable "purge_protection_enabled" {
  type        = bool
  description = "Enable purge protection"
  default     = true
}

variable "soft_delete_retention_days" {
  type        = number
  description = "Soft delete retention days"
  default     = 90
}

variable "public_network_access_enabled" {
  type        = bool
  description = "Enable public network access"
  default     = false
}

variable "enable_network_acls" {
  type        = bool
  description = "Enable network ACLs"
  default     = true
}

variable "network_acls_bypass" {
  type        = string
  description = "Network ACLs bypass"
  default     = "AzureServices"
}

variable "network_acls_default_action" {
  type        = string
  description = "Network ACLs default action"
  default     = "Deny"
}

variable "network_acls_ip_rules" {
  type        = list(string)
  description = "Network ACLs IP rules"
  default     = []
}

variable "network_acls_subnet_ids" {
  type        = list(string)
  description = "Network ACLs subnet IDs"
  default     = []
}

variable "role_assignments" {
  type        = map(any)
  description = "Role assignments for the Key Vault"
  default     = {}
}

variable "diagnostic_settings" {
  type        = map(any)
  description = "Diagnostic settings for the Key Vault"
  default     = {}
}

variable "private_endpoints" {
  type        = map(any)
  description = "Private endpoint configurations"
  default     = {}
}

variable "tags" {
  type        = map(string)
  description = "Tags to apply to the Key Vault"
  default     = {}
}
