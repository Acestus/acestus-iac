# Acestus Metric Alert Module Variables

variable "name" {
  type        = string
  description = "The name of the Metric Alert"
}

variable "resource_group_name" {
  type        = string
  description = "The name of the resource group"
}

variable "scopes" {
  type        = list(string)
  description = "List of resource IDs to monitor"
}

variable "description" {
  type        = string
  description = "Description of the Metric Alert"
  default     = ""
}

variable "severity" {
  type        = number
  description = "Severity of the alert (0-4, where 0 is Critical)"
  default     = 2
  validation {
    condition     = var.severity >= 0 && var.severity <= 4
    error_message = "Severity must be between 0 and 4."
  }
}

variable "enabled" {
  type        = bool
  description = "Enable the Metric Alert"
  default     = true
}

variable "frequency" {
  type        = string
  description = "How often the metric is evaluated"
  default     = "PT5M"
  validation {
    condition     = can(regex("^PT[0-9]+[MH]$", var.frequency))
    error_message = "Frequency must be in ISO 8601 duration format (e.g., PT5M, PT1H)."
  }
}

variable "window_size" {
  type        = string
  description = "The period of time used to monitor alert activity"
  default     = "PT15M"
  validation {
    condition     = can(regex("^PT[0-9]+[MH]$", var.window_size))
    error_message = "Window size must be in ISO 8601 duration format (e.g., PT15M, PT1H)."
  }
}

variable "criteria" {
  type = object({
    metric_namespace = string
    metric_name      = string
    aggregation      = string
    operator         = string
    threshold        = number
    dimensions = optional(list(object({
      name     = string
      operator = string
      values   = list(string)
    })), [])
    skip_metric_validation = optional(bool, false)
  })
  description = "Criteria for the Metric Alert"

  validation {
    condition     = contains(["Average", "Count", "Maximum", "Minimum", "Total"], var.criteria.aggregation)
    error_message = "Aggregation must be one of: Average, Count, Maximum, Minimum, Total."
  }

  validation {
    condition     = contains(["Equals", "GreaterThan", "GreaterThanOrEqual", "LessThan", "LessThanOrEqual", "NotEquals"], var.criteria.operator)
    error_message = "Operator must be one of: Equals, GreaterThan, GreaterThanOrEqual, LessThan, LessThanOrEqual, NotEquals."
  }
}

variable "action" {
  type = list(object({
    action_group_id    = string
    webhook_properties = optional(map(string), {})
  }))
  description = "List of actions to trigger when the alert fires"
  default     = []
}

variable "auto_mitigate" {
  type        = bool
  description = "Automatically resolve the alert when the condition is no longer true"
  default     = true
}

variable "tags" {
  type        = map(string)
  description = "Tags to apply to the Metric Alert"
  default     = {}
}
