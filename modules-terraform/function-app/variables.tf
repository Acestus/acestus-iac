# Acestus Function App Module Variables

variable "name" {
  type        = string
  description = "The name of the Function App"
}

variable "resource_group_name" {
  type        = string
  description = "The name of the resource group"
}

variable "location" {
  type        = string
  description = "The Azure region for the Function App"
}

variable "service_plan_id" {
  type        = string
  description = "The resource ID of the App Service Plan"
}

variable "storage_account_name" {
  type        = string
  description = "The name of the Storage Account for the Function App"
}

variable "storage_account_access_key" {
  type        = string
  description = "The access key for the Storage Account"
  sensitive   = true
  default     = null
}

variable "storage_uses_managed_identity" {
  type        = bool
  description = "Use managed identity for storage access instead of access key"
  default     = true
}

variable "functions_extension_version" {
  type        = string
  description = "The runtime version of the Function App"
  default     = "~4"
  validation {
    condition     = can(regex("^~[1-4]$", var.functions_extension_version))
    error_message = "Functions extension version must be ~1, ~2, ~3, or ~4."
  }
}

variable "os_type" {
  type        = string
  description = "The OS type for the Function App"
  default     = "Linux"
  validation {
    condition     = contains(["Linux", "Windows"], var.os_type)
    error_message = "OS type must be 'Linux' or 'Windows'."
  }
}

variable "app_settings" {
  type        = map(string)
  description = "Application settings for the Function App"
  default     = {}
}

variable "connection_strings" {
  type = map(object({
    type  = string
    value = string
  }))
  description = "Connection strings for the Function App"
  default     = {}
}

variable "managed_identities" {
  type = object({
    system_assigned            = optional(bool, false)
    user_assigned_resource_ids = optional(set(string), [])
  })
  description = "Managed identity configuration"
  default = {
    system_assigned = true
  }
}

variable "private_endpoints" {
  type        = map(any)
  description = "Private endpoint configurations"
  default     = {}
}

variable "site_config" {
  type        = any
  description = "Site configuration for the Function App"
  default     = {}
}

variable "https_only" {
  type        = bool
  description = "Force HTTPS only"
  default     = true
}

variable "public_network_access_enabled" {
  type        = bool
  description = "Enable public network access"
  default     = false
}

variable "ftps_state" {
  type        = string
  description = "FTPS state for the Function App"
  default     = "Disabled"
  validation {
    condition     = contains(["Disabled", "FtpsOnly", "AllAllowed"], var.ftps_state)
    error_message = "FTPS state must be 'Disabled', 'FtpsOnly', or 'AllAllowed'."
  }
}

variable "minimum_tls_version" {
  type        = string
  description = "Minimum TLS version"
  default     = "1.2"
  validation {
    condition     = contains(["1.0", "1.1", "1.2"], var.minimum_tls_version)
    error_message = "Minimum TLS version must be '1.0', '1.1', or '1.2'."
  }
}

variable "virtual_network_subnet_id" {
  type        = string
  description = "The subnet ID for VNet integration"
  default     = null
}

variable "diagnostic_settings" {
  type        = map(any)
  description = "Diagnostic settings for the Function App"
  default     = {}
}

variable "role_assignments" {
  type        = map(any)
  description = "Role assignments for the Function App"
  default     = {}
}

variable "tags" {
  type        = map(string)
  description = "Tags to apply to the Function App"
  default     = {}
}
