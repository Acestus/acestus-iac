# Acestus Application Gateway WAF Policy Module Variables

variable "name" {
  type        = string
  description = "The name of the WAF policy"
}

variable "resource_group_name" {
  type        = string
  description = "The name of the resource group"
}

variable "location" {
  type        = string
  description = "The Azure region for the WAF policy"
}

variable "policy_mode" {
  type        = string
  description = "The mode of the WAF policy (Detection or Prevention)"
  default     = "Prevention"
  validation {
    condition     = contains(["Detection", "Prevention"], var.policy_mode)
    error_message = "Policy mode must be either 'Detection' or 'Prevention'."
  }
}

variable "policy_state" {
  type        = string
  description = "The state of the WAF policy (Enabled or Disabled)"
  default     = "Enabled"
  validation {
    condition     = contains(["Enabled", "Disabled"], var.policy_state)
    error_message = "Policy state must be either 'Enabled' or 'Disabled'."
  }
}

variable "request_body_check" {
  type        = bool
  description = "Enable request body inspection"
  default     = true
}

variable "max_request_body_size_in_kb" {
  type        = number
  description = "Maximum request body size in KB"
  default     = 128
  validation {
    condition     = var.max_request_body_size_in_kb >= 8 && var.max_request_body_size_in_kb <= 128
    error_message = "Max request body size must be between 8 and 128 KB."
  }
}

variable "file_upload_limit_in_mb" {
  type        = number
  description = "Maximum file upload size in MB"
  default     = 100
  validation {
    condition     = var.file_upload_limit_in_mb >= 1 && var.file_upload_limit_in_mb <= 4000
    error_message = "File upload limit must be between 1 and 4000 MB."
  }
}

variable "managed_rules" {
  type = list(object({
    type    = string
    version = string
    rule_group_overrides = optional(list(object({
      rule_group_name = string
      rules = optional(list(object({
        id      = string
        enabled = optional(bool, true)
        action  = optional(string)
      })), [])
    })), [])
  }))
  description = "List of managed rule sets to apply"
  default = [
    {
      type    = "OWASP"
      version = "3.2"
    }
  ]
}

variable "custom_rules" {
  type = list(object({
    name      = string
    priority  = number
    rule_type = string
    action    = string
    match_conditions = list(object({
      match_variables = list(object({
        variable_name = string
        selector      = optional(string)
      }))
      operator           = string
      negation_condition = optional(bool, false)
      match_values       = list(string)
      transforms         = optional(list(string), [])
    }))
  }))
  description = "List of custom WAF rules"
  default     = []
}

variable "tags" {
  type        = map(string)
  description = "Tags to apply to the WAF policy"
  default     = {}
}
