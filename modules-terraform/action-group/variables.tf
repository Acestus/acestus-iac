# Acestus Action Group Module Variables

variable "name" {
  type        = string
  description = "The name of the Action Group"
}

variable "resource_group_name" {
  type        = string
  description = "The name of the resource group"
}

variable "short_name" {
  type        = string
  description = "The short name of the Action Group (max 12 characters)"
  validation {
    condition     = length(var.short_name) <= 12
    error_message = "Short name must be 12 characters or less."
  }
}

variable "enabled" {
  type        = bool
  description = "Enable the Action Group"
  default     = true
}

variable "email_receivers" {
  type = list(object({
    name                    = string
    email_address           = string
    use_common_alert_schema = optional(bool, true)
  }))
  description = "List of email receivers"
  default     = []
}

variable "sms_receivers" {
  type = list(object({
    name         = string
    country_code = string
    phone_number = string
  }))
  description = "List of SMS receivers"
  default     = []
}

variable "webhook_receivers" {
  type = list(object({
    name                    = string
    service_uri             = string
    use_common_alert_schema = optional(bool, true)
    aad_auth = optional(object({
      object_id      = string
      identifier_uri = optional(string)
      tenant_id      = optional(string)
    }))
  }))
  description = "List of webhook receivers"
  default     = []
}

variable "azure_app_push_receivers" {
  type = list(object({
    name          = string
    email_address = string
  }))
  description = "List of Azure app push receivers"
  default     = []
}

variable "logic_app_receivers" {
  type = list(object({
    name                    = string
    resource_id             = string
    callback_url            = string
    use_common_alert_schema = optional(bool, true)
  }))
  description = "List of Logic App receivers"
  default     = []
}

variable "azure_function_receivers" {
  type = list(object({
    name                     = string
    function_app_resource_id = string
    function_name            = string
    http_trigger_url         = string
    use_common_alert_schema  = optional(bool, true)
  }))
  description = "List of Azure Function receivers"
  default     = []
}

variable "arm_role_receivers" {
  type = list(object({
    name                    = string
    role_id                 = string
    use_common_alert_schema = optional(bool, true)
  }))
  description = "List of ARM role receivers"
  default     = []
}

variable "tags" {
  type        = map(string)
  description = "Tags to apply to the Action Group"
  default     = {}
}
