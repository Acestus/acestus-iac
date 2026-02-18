# Acestus Application Insights Module Variables

variable "name" {
  type        = string
  description = "The name of the Application Insights component"
}

variable "resource_group_name" {
  type        = string
  description = "The name of the resource group"
}

variable "location" {
  type        = string
  description = "The Azure region for the Application Insights component"
}

variable "application_type" {
  type        = string
  description = "The type of application being monitored"
  default     = "web"
  validation {
    condition     = contains(["web", "ios", "java", "MobileCenter", "Node.JS", "other", "phone", "store"], var.application_type)
    error_message = "Application type must be a valid Application Insights application type."
  }
}

variable "retention_in_days" {
  type        = number
  description = "Specifies the retention period in days"
  default     = 90
  validation {
    condition     = contains([30, 60, 90, 120, 180, 270, 365, 550, 730], var.retention_in_days)
    error_message = "Retention must be one of: 30, 60, 90, 120, 180, 270, 365, 550, 730 days."
  }
}

variable "workspace_id" {
  type        = string
  description = "The Log Analytics Workspace resource ID to send data to"
}

variable "daily_data_cap_in_gb" {
  type        = number
  description = "Daily data cap in GB. Use 0 for no cap."
  default     = 0
}

variable "daily_data_cap_notifications_disabled" {
  type        = bool
  description = "Disable daily data cap notifications"
  default     = false
}

variable "sampling_percentage" {
  type        = number
  description = "The percentage of telemetry to sample"
  default     = 100
  validation {
    condition     = var.sampling_percentage >= 0 && var.sampling_percentage <= 100
    error_message = "Sampling percentage must be between 0 and 100."
  }
}

variable "disable_ip_masking" {
  type        = bool
  description = "Disable IP masking"
  default     = false
}

variable "local_authentication_disabled" {
  type        = bool
  description = "Disable local authentication (require AAD)"
  default     = true
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

variable "role_assignments" {
  type        = map(any)
  description = "Role assignments for the Application Insights component"
  default     = {}
}

variable "diagnostic_settings" {
  type        = map(any)
  description = "Diagnostic settings for the Application Insights component"
  default     = {}
}

variable "tags" {
  type        = map(string)
  description = "Tags to apply to the Application Insights component"
  default     = {}
}
