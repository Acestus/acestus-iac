# Acestus App Service Plan Module Variables

variable "name" {
  type        = string
  description = "The name of the App Service Plan"
}

variable "resource_group_name" {
  type        = string
  description = "The name of the resource group"
}

variable "location" {
  type        = string
  description = "The Azure region for the App Service Plan"
}

variable "os_type" {
  type        = string
  description = "The OS type for the App Service Plan"
  default     = "Linux"
  validation {
    condition     = contains(["Linux", "Windows", "WindowsContainer"], var.os_type)
    error_message = "OS type must be 'Linux', 'Windows', or 'WindowsContainer'."
  }
}

variable "sku_name" {
  type        = string
  description = "The SKU name for the App Service Plan"
  default     = "P1v3"
  validation {
    condition     = can(regex("^(B[1-3]|S[1-3]|P[0-3]v[2-3]|I[1-6]v2|Y1|EP[1-3]|WS[1-3]|FC1)$", var.sku_name))
    error_message = "SKU name must be a valid App Service Plan SKU."
  }
}

variable "maximum_elastic_worker_count" {
  type        = number
  description = "Maximum number of elastic workers for Elastic Premium plans"
  default     = null
}

variable "worker_count" {
  type        = number
  description = "The number of workers for the App Service Plan"
  default     = null
}

variable "per_site_scaling_enabled" {
  type        = bool
  description = "Enable per-site scaling"
  default     = false
}

variable "zone_balancing_enabled" {
  type        = bool
  description = "Enable zone balancing for high availability"
  default     = false
}

variable "role_assignments" {
  type        = map(any)
  description = "Role assignments for the App Service Plan"
  default     = {}
}

variable "diagnostic_settings" {
  type        = map(any)
  description = "Diagnostic settings for the App Service Plan"
  default     = {}
}

variable "tags" {
  type        = map(string)
  description = "Tags to apply to the App Service Plan"
  default     = {}
}
