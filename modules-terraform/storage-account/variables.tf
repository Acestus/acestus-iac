# Acestus Storage Account Module Variables

variable "name" {
  type        = string
  description = "The name of the storage account (3-24 lowercase alphanumeric)"
}

variable "resource_group_name" {
  type        = string
  description = "The name of the resource group"
}

variable "location" {
  type        = string
  description = "The Azure region for the storage account"
}

variable "account_tier" {
  type        = string
  description = "The storage account tier"
  default     = "Standard"
}

variable "account_replication_type" {
  type        = string
  description = "The storage account replication type"
  default     = "ZRS"
}

variable "account_kind" {
  type        = string
  description = "The storage account kind"
  default     = "StorageV2"
}

variable "access_tier" {
  type        = string
  description = "The access tier for blob storage"
  default     = "Hot"
}

variable "https_traffic_only_enabled" {
  type        = bool
  description = "Enable HTTPS traffic only"
  default     = true
}

variable "min_tls_version" {
  type        = string
  description = "Minimum TLS version"
  default     = "TLS1_2"
}

variable "public_network_access_enabled" {
  type        = bool
  description = "Enable public network access"
  default     = false
}

variable "shared_access_key_enabled" {
  type        = bool
  description = "Enable shared access key"
  default     = false
}

variable "infrastructure_encryption_enabled" {
  type        = bool
  description = "Enable infrastructure encryption"
  default     = true
}

variable "allow_nested_items_to_be_public" {
  type        = bool
  description = "Allow nested items to be public"
  default     = false
}

variable "network_rules" {
  type        = any
  description = "Network rules configuration"
  default     = null
}

variable "blob_properties" {
  type        = any
  description = "Blob properties configuration"
  default     = null
}

variable "containers" {
  type        = map(any)
  description = "Blob containers to create"
  default     = {}
}

variable "role_assignments" {
  type        = map(any)
  description = "Role assignments for the storage account"
  default     = {}
}

variable "diagnostic_settings" {
  type        = map(any)
  description = "Diagnostic settings for the storage account"
  default     = {}
}

variable "private_endpoints" {
  type        = map(any)
  description = "Private endpoint configurations"
  default     = {}
}

variable "managed_identities" {
  type        = any
  description = "Managed identity configuration"
  default     = null
}

variable "tags" {
  type        = map(string)
  description = "Tags to apply to the storage account"
  default     = {}
}
