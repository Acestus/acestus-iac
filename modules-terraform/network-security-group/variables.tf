# Acestus Network Security Group Module Variables

variable "name" {
  type        = string
  description = "The name of the network security group"
}

variable "resource_group_name" {
  type        = string
  description = "The name of the resource group"
}

variable "location" {
  type        = string
  description = "The Azure region for the network security group"
}

variable "security_rules" {
  type = map(object({
    name                                       = string
    access                                     = string
    direction                                  = string
    priority                                   = number
    protocol                                   = string
    description                                = optional(string)
    source_port_range                          = optional(string)
    source_port_ranges                         = optional(list(string))
    destination_port_range                     = optional(string)
    destination_port_ranges                    = optional(list(string))
    source_address_prefix                      = optional(string)
    source_address_prefixes                    = optional(list(string))
    source_application_security_group_ids      = optional(list(string))
    destination_address_prefix                 = optional(string)
    destination_address_prefixes               = optional(list(string))
    destination_application_security_group_ids = optional(list(string))
  }))
  description = "Map of security rules to apply to the network security group"
  default     = {}
}

variable "role_assignments" {
  type        = map(any)
  description = "Role assignments for the network security group"
  default     = {}
}

variable "diagnostic_settings" {
  type        = map(any)
  description = "Diagnostic settings for the network security group"
  default     = {}
}

variable "tags" {
  type        = map(string)
  description = "Tags to apply to the network security group"
  default     = {}
}
