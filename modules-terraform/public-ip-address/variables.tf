# Acestus Public IP Address Module Variables

variable "name" {
  type        = string
  description = "The name of the public IP address"
}

variable "resource_group_name" {
  type        = string
  description = "The name of the resource group"
}

variable "location" {
  type        = string
  description = "The Azure region for the public IP address"
}

variable "sku" {
  type        = string
  description = "The SKU of the public IP address (Standard recommended for security)"
  default     = "Standard"
  validation {
    condition     = contains(["Basic", "Standard"], var.sku)
    error_message = "SKU must be either 'Basic' or 'Standard'."
  }
}

variable "sku_tier" {
  type        = string
  description = "The SKU tier of the public IP address"
  default     = "Regional"
  validation {
    condition     = contains(["Regional", "Global"], var.sku_tier)
    error_message = "SKU tier must be either 'Regional' or 'Global'."
  }
}

variable "allocation_method" {
  type        = string
  description = "The allocation method for the public IP address"
  default     = "Static"
  validation {
    condition     = contains(["Static", "Dynamic"], var.allocation_method)
    error_message = "Allocation method must be either 'Static' or 'Dynamic'."
  }
}

variable "ip_version" {
  type        = string
  description = "The IP version for the public IP address"
  default     = "IPv4"
  validation {
    condition     = contains(["IPv4", "IPv6"], var.ip_version)
    error_message = "IP version must be either 'IPv4' or 'IPv6'."
  }
}

variable "zones" {
  type        = list(string)
  description = "Availability zones for the public IP address"
  default     = null
}

variable "domain_name_label" {
  type        = string
  description = "The DNS label for the public IP address"
  default     = null
}

variable "reverse_fqdn" {
  type        = string
  description = "The reverse FQDN for the public IP address"
  default     = null
}

variable "idle_timeout_in_minutes" {
  type        = number
  description = "The idle timeout in minutes for the public IP address"
  default     = 4
  validation {
    condition     = var.idle_timeout_in_minutes >= 4 && var.idle_timeout_in_minutes <= 30
    error_message = "Idle timeout must be between 4 and 30 minutes."
  }
}

variable "ddos_protection_mode" {
  type        = string
  description = "The DDoS protection mode for the public IP address"
  default     = "VirtualNetworkInherited"
  validation {
    condition     = contains(["Disabled", "Enabled", "VirtualNetworkInherited"], var.ddos_protection_mode)
    error_message = "DDoS protection mode must be 'Disabled', 'Enabled', or 'VirtualNetworkInherited'."
  }
}

variable "role_assignments" {
  type        = map(any)
  description = "Role assignments for the public IP address"
  default     = {}
}

variable "diagnostic_settings" {
  type        = map(any)
  description = "Diagnostic settings for the public IP address"
  default     = {}
}

variable "tags" {
  type        = map(string)
  description = "Tags to apply to the public IP address"
  default     = {}
}
