# Acestus Event Grid Topic Module Variables

variable "name" {
  type        = string
  description = "The name of the Event Grid Topic"
}

variable "resource_group_name" {
  type        = string
  description = "The name of the resource group"
}

variable "location" {
  type        = string
  description = "The Azure region for the Event Grid Topic"
}

variable "input_schema" {
  type        = string
  description = "The schema for incoming events"
  default     = "EventGridSchema"
  validation {
    condition     = contains(["EventGridSchema", "CloudEventSchemaV1_0", "CustomEventSchema"], var.input_schema)
    error_message = "Input schema must be one of: EventGridSchema, CloudEventSchemaV1_0, CustomEventSchema."
  }
}

variable "public_network_access_enabled" {
  type        = bool
  description = "Enable public network access (Acestus default: disabled for security)"
  default     = false
}

variable "local_auth_enabled" {
  type        = bool
  description = "Enable local authentication using access keys (Acestus default: disabled for security)"
  default     = false
}

variable "inbound_ip_rules" {
  type = list(object({
    ip_mask = string
    action  = optional(string, "Allow")
  }))
  description = "List of inbound IP rules for network filtering"
  default     = []
}

variable "managed_identities" {
  type = object({
    system_assigned            = optional(bool, false)
    user_assigned_resource_ids = optional(set(string), [])
  })
  description = "Managed identity configuration"
  default     = {}
}

variable "role_assignments" {
  type        = map(any)
  description = "Role assignments for the Event Grid Topic"
  default     = {}
}

variable "private_endpoints" {
  type        = map(any)
  description = "Private endpoints for the Event Grid Topic"
  default     = {}
}

variable "diagnostic_settings" {
  type        = map(any)
  description = "Diagnostic settings for the Event Grid Topic"
  default     = {}
}

variable "tags" {
  type        = map(string)
  description = "Tags to apply to the Event Grid Topic"
  default     = {}
}
