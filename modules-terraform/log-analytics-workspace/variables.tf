# Acestus Log Analytics Workspace Module Variables

variable "name" {
  type        = string
  description = "The name of the Log Analytics Workspace"
}

variable "resource_group_name" {
  type        = string
  description = "The name of the resource group"
}

variable "location" {
  type        = string
  description = "The Azure region for the Log Analytics Workspace"
}

variable "sku" {
  type        = string
  description = "The SKU of the Log Analytics Workspace"
  default     = "PerGB2018"
  validation {
    condition     = contains(["Free", "PerNode", "Premium", "Standard", "Standalone", "Unlimited", "CapacityReservation", "PerGB2018"], var.sku)
    error_message = "SKU must be a valid Log Analytics Workspace SKU."
  }
}

variable "retention_in_days" {
  type        = number
  description = "The workspace data retention in days"
  default     = 30
  validation {
    condition     = var.retention_in_days >= 30 && var.retention_in_days <= 730
    error_message = "Retention must be between 30 and 730 days."
  }
}

variable "daily_quota_gb" {
  type        = number
  description = "The daily ingestion quota in GB. Use -1 for unlimited."
  default     = -1
}

variable "internet_ingestion_enabled" {
  type        = bool
  description = "Enable internet ingestion"
  default     = true
}

variable "internet_query_enabled" {
  type        = bool
  description = "Enable internet query"
  default     = true
}

variable "reservation_capacity_in_gb_per_day" {
  type        = number
  description = "The capacity reservation level in GB per day. Only valid with CapacityReservation SKU."
  default     = null
}

variable "local_authentication_disabled" {
  type        = bool
  description = "Disable local authentication (require AAD)"
  default     = false
}

variable "allow_resource_only_permissions" {
  type        = bool
  description = "Allow resource-only permissions"
  default     = true
}

variable "cmk_for_query_forced" {
  type        = bool
  description = "Force customer-managed key for query"
  default     = false
}

variable "role_assignments" {
  type        = map(any)
  description = "Role assignments for the Log Analytics Workspace"
  default     = {}
}

variable "diagnostic_settings" {
  type        = map(any)
  description = "Diagnostic settings for the Log Analytics Workspace"
  default     = {}
}

variable "tags" {
  type        = map(string)
  description = "Tags to apply to the Log Analytics Workspace"
  default     = {}
}
