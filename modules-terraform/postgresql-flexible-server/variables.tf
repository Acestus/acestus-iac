# Acestus PostgreSQL Flexible Server Module Variables

variable "name" {
  type        = string
  description = "The name of the PostgreSQL Flexible Server"
}

variable "resource_group_name" {
  type        = string
  description = "The name of the resource group"
}

variable "location" {
  type        = string
  description = "The Azure region for the PostgreSQL Flexible Server"
}

variable "sku_name" {
  type        = string
  description = "The SKU name for the PostgreSQL Flexible Server"
  default     = "GP_Standard_D2s_v3"
}

variable "postgresql_version" {
  type        = string
  description = "The version of PostgreSQL"
  default     = "16"
  validation {
    condition     = contains(["11", "12", "13", "14", "15", "16"], var.postgresql_version)
    error_message = "PostgreSQL version must be 11, 12, 13, 14, 15, or 16."
  }
}

variable "storage_mb" {
  type        = number
  description = "Storage size in MB"
  default     = 32768
  validation {
    condition     = var.storage_mb >= 32768 && var.storage_mb <= 33554432
    error_message = "Storage must be between 32768 MB (32 GB) and 33554432 MB (32 TB)."
  }
}

variable "storage_tier" {
  type        = string
  description = "The storage tier for the PostgreSQL Flexible Server"
  default     = null
}

variable "backup_retention_days" {
  type        = number
  description = "Backup retention days"
  default     = 7
  validation {
    condition     = var.backup_retention_days >= 7 && var.backup_retention_days <= 35
    error_message = "Backup retention must be between 7 and 35 days."
  }
}

variable "geo_redundant_backup_enabled" {
  type        = bool
  description = "Enable geo-redundant backup"
  default     = false
}

variable "create_mode" {
  type        = string
  description = "The creation mode for the server"
  default     = "Default"
  validation {
    condition     = contains(["Default", "GeoRestore", "PointInTimeRestore", "Replica", "Update"], var.create_mode)
    error_message = "Create mode must be one of: Default, GeoRestore, PointInTimeRestore, Replica, Update."
  }
}

variable "administrator_login" {
  type        = string
  description = "The administrator login name"
  default     = null
}

variable "administrator_password" {
  type        = string
  description = "The administrator password"
  sensitive   = true
  default     = null
}

variable "authentication" {
  type = object({
    active_directory_auth_enabled = optional(bool, true)
    password_auth_enabled         = optional(bool, false)
    tenant_id                     = optional(string)
  })
  description = "Authentication configuration (Acestus default: AAD-only)"
  default = {
    active_directory_auth_enabled = true
    password_auth_enabled         = false
  }
}

variable "delegated_subnet_id" {
  type        = string
  description = "The subnet ID for private access"
  default     = null
}

variable "private_dns_zone_id" {
  type        = string
  description = "The private DNS zone ID"
  default     = null
}

variable "public_network_access_enabled" {
  type        = bool
  description = "Enable public network access"
  default     = false
}

variable "high_availability" {
  type = object({
    mode                      = string
    standby_availability_zone = optional(string)
  })
  description = "High availability configuration"
  default     = null
}

variable "maintenance_window" {
  type = object({
    day_of_week  = optional(number, 0)
    start_hour   = optional(number, 0)
    start_minute = optional(number, 0)
  })
  description = "Maintenance window configuration"
  default     = null
}

variable "zone" {
  type        = string
  description = "The availability zone for the server"
  default     = null
}

variable "databases" {
  type = map(object({
    charset   = optional(string, "UTF8")
    collation = optional(string, "en_US.utf8")
  }))
  description = "Databases to create"
  default     = {}
}

variable "server_configurations" {
  type        = map(string)
  description = "Server configuration parameters"
  default     = {}
}

variable "firewall_rules" {
  type = map(object({
    start_ip_address = string
    end_ip_address   = string
  }))
  description = "Firewall rules for the server"
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

variable "role_assignments" {
  type        = map(any)
  description = "Role assignments for the PostgreSQL Flexible Server"
  default     = {}
}

variable "diagnostic_settings" {
  type        = map(any)
  description = "Diagnostic settings for the PostgreSQL Flexible Server"
  default     = {}
}

variable "tags" {
  type        = map(string)
  description = "Tags to apply to the PostgreSQL Flexible Server"
  default     = {}
}
