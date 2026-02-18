# Acestus Virtual Network Module Variables

variable "name" {
  type        = string
  description = "The name of the virtual network"
}

variable "resource_group_name" {
  type        = string
  description = "The name of the resource group"
}

variable "location" {
  type        = string
  description = "The Azure region for the virtual network"
}

variable "address_space" {
  type        = list(string)
  description = "The address space for the virtual network"
}

variable "dns_servers" {
  type        = list(string)
  description = "Custom DNS servers for the virtual network"
  default     = []
}

variable "subnets" {
  type        = map(any)
  description = "Subnets to create within the virtual network"
  default     = {}
}

variable "ddos_protection_plan" {
  type        = any
  description = "DDoS protection plan configuration"
  default     = null
}

variable "peerings" {
  type        = map(any)
  description = "Virtual network peering configurations"
  default     = {}
}

variable "role_assignments" {
  type        = map(any)
  description = "Role assignments for the virtual network"
  default     = {}
}

variable "diagnostic_settings" {
  type        = map(any)
  description = "Diagnostic settings for the virtual network"
  default     = {}
}

variable "tags" {
  type        = map(string)
  description = "Tags to apply to the virtual network"
  default     = {}
}
