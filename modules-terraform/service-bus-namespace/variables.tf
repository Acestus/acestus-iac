# Acestus Service Bus Namespace Module Variables

variable "name" {
  type        = string
  description = "The name of the Service Bus Namespace"
}

variable "resource_group_name" {
  type        = string
  description = "The name of the resource group"
}

variable "location" {
  type        = string
  description = "The Azure region for the Service Bus Namespace"
}

variable "sku" {
  type        = string
  description = "The SKU of the Service Bus Namespace"
  default     = "Premium"
  validation {
    condition     = contains(["Basic", "Standard", "Premium"], var.sku)
    error_message = "SKU must be 'Basic', 'Standard', or 'Premium'."
  }
}

variable "capacity" {
  type        = number
  description = "The capacity (messaging units) for Premium SKU"
  default     = 1
  validation {
    condition     = contains([0, 1, 2, 4, 8, 16], var.capacity)
    error_message = "Capacity must be 0, 1, 2, 4, 8, or 16."
  }
}

variable "premium_messaging_partitions" {
  type        = number
  description = "The number of messaging partitions for Premium SKU"
  default     = 1
  validation {
    condition     = contains([1, 2, 4], var.premium_messaging_partitions)
    error_message = "Premium messaging partitions must be 1, 2, or 4."
  }
}

variable "public_network_access_enabled" {
  type        = bool
  description = "Enable public network access"
  default     = false
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

variable "local_auth_enabled" {
  type        = bool
  description = "Enable local/SAS authentication (disable to enforce AAD-only)"
  default     = false
}

variable "zone_redundant" {
  type        = bool
  description = "Enable zone redundancy for Premium SKU"
  default     = true
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

variable "network_rule_set" {
  type        = any
  description = "Network rule set configuration"
  default     = null
}

variable "queues" {
  type        = map(any)
  description = "Service Bus queues to create"
  default     = {}
}

variable "topics" {
  type        = map(any)
  description = "Service Bus topics to create"
  default     = {}
}

variable "role_assignments" {
  type        = map(any)
  description = "Role assignments for the Service Bus Namespace"
  default     = {}
}

variable "diagnostic_settings" {
  type        = map(any)
  description = "Diagnostic settings for the Service Bus Namespace"
  default     = {}
}

variable "private_endpoints" {
  type        = map(any)
  description = "Private endpoint configurations"
  default     = {}
}

variable "tags" {
  type        = map(string)
  description = "Tags to apply to the Service Bus Namespace"
  default     = {}
}
