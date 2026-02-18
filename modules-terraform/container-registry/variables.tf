# Acestus Container Registry Module Variables

variable "name" {
  type        = string
  description = "The name of the container registry (globally unique, 5-50 alphanumeric)"
}

variable "resource_group_name" {
  type        = string
  description = "The name of the resource group"
}

variable "location" {
  type        = string
  description = "The Azure region for the container registry"
}

variable "sku" {
  type        = string
  description = "The SKU of the container registry"
  default     = "Premium"
  validation {
    condition     = contains(["Basic", "Standard", "Premium"], var.sku)
    error_message = "SKU must be 'Basic', 'Standard', or 'Premium'."
  }
}

variable "admin_enabled" {
  type        = bool
  description = "Enable admin user"
  default     = false
}

variable "public_network_access_enabled" {
  type        = bool
  description = "Enable public network access"
  default     = false
}

variable "network_rule_bypass_option" {
  type        = string
  description = "Network rule bypass option"
  default     = "AzureServices"
}

variable "network_rule_set" {
  type        = any
  description = "Network rule set configuration"
  default     = null
}

variable "zone_redundancy_enabled" {
  type        = bool
  description = "Enable zone redundancy (Premium SKU only)"
  default     = true
}

variable "anonymous_pull_enabled" {
  type        = bool
  description = "Enable anonymous pull"
  default     = false
}

variable "data_endpoint_enabled" {
  type        = bool
  description = "Enable data endpoint (Premium SKU only)"
  default     = false
}

variable "retention_policy_in_days" {
  type        = number
  description = "Retention policy days for untagged manifests"
  default     = 30
}

variable "retention_policy_enabled" {
  type        = bool
  description = "Enable retention policy"
  default     = true
}

variable "encryption" {
  type        = any
  description = "Encryption configuration with CMK"
  default     = null
}

variable "managed_identities" {
  type        = any
  description = "Managed identity configuration"
  default     = null
}

variable "role_assignments" {
  type        = map(any)
  description = "Role assignments for the container registry"
  default     = {}
}

variable "diagnostic_settings" {
  type        = map(any)
  description = "Diagnostic settings for the container registry"
  default     = {}
}

variable "private_endpoints" {
  type        = map(any)
  description = "Private endpoint configurations"
  default     = {}
}

variable "tags" {
  type        = map(string)
  description = "Tags to apply to the container registry"
  default     = {}
}
