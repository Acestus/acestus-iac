# Acestus Load Balancer Module Variables

variable "name" {
  type        = string
  description = "The name of the load balancer"
}

variable "resource_group_name" {
  type        = string
  description = "The name of the resource group"
}

variable "location" {
  type        = string
  description = "The Azure region for the load balancer"
}

variable "sku" {
  type        = string
  description = "The SKU of the load balancer (Standard recommended for security)"
  default     = "Standard"
  validation {
    condition     = contains(["Basic", "Standard", "Gateway"], var.sku)
    error_message = "SKU must be 'Basic', 'Standard', or 'Gateway'."
  }
}

variable "sku_tier" {
  type        = string
  description = "The SKU tier of the load balancer"
  default     = "Regional"
  validation {
    condition     = contains(["Regional", "Global"], var.sku_tier)
    error_message = "SKU tier must be either 'Regional' or 'Global'."
  }
}

variable "frontend_ip_configurations" {
  type = map(object({
    name                                               = string
    public_ip_address_id                               = optional(string)
    subnet_id                                          = optional(string)
    private_ip_address                                 = optional(string)
    private_ip_address_allocation                      = optional(string, "Dynamic")
    private_ip_address_version                         = optional(string, "IPv4")
    zones                                              = optional(list(string))
    gateway_load_balancer_frontend_ip_configuration_id = optional(string)
  }))
  description = "Map of frontend IP configurations for the load balancer"
  default     = {}
}

variable "backend_address_pools" {
  type = map(object({
    name = string
  }))
  description = "Map of backend address pools for the load balancer"
  default     = {}
}

variable "health_probes" {
  type = map(object({
    name                = string
    protocol            = string
    port                = number
    request_path        = optional(string)
    interval_in_seconds = optional(number, 5)
    number_of_probes    = optional(number, 2)
  }))
  description = "Map of health probes for the load balancer"
  default     = {}
}

variable "lb_rules" {
  type = map(object({
    name                           = string
    frontend_ip_configuration_name = string
    backend_address_pool_names     = optional(list(string), [])
    probe_name                     = optional(string)
    protocol                       = string
    frontend_port                  = number
    backend_port                   = number
    enable_floating_ip             = optional(bool, false)
    idle_timeout_in_minutes        = optional(number, 4)
    load_distribution              = optional(string, "Default")
    disable_outbound_snat          = optional(bool, false)
    enable_tcp_reset               = optional(bool, false)
  }))
  description = "Map of load balancer rules"
  default     = {}
}

variable "nat_rules" {
  type = map(object({
    name                           = string
    frontend_ip_configuration_name = string
    protocol                       = string
    frontend_port                  = optional(number)
    backend_port                   = number
    frontend_port_start            = optional(number)
    frontend_port_end              = optional(number)
    backend_address_pool_name      = optional(string)
    idle_timeout_in_minutes        = optional(number, 4)
    enable_floating_ip             = optional(bool, false)
    enable_tcp_reset               = optional(bool, false)
  }))
  description = "Map of NAT rules for the load balancer"
  default     = {}
}

variable "outbound_rules" {
  type = map(object({
    name                           = string
    frontend_ip_configuration_name = string
    backend_address_pool_name      = string
    protocol                       = string
    idle_timeout_in_minutes        = optional(number, 4)
    enable_tcp_reset               = optional(bool, false)
    allocated_outbound_ports       = optional(number)
  }))
  description = "Map of outbound rules for the load balancer"
  default     = {}
}

variable "role_assignments" {
  type        = map(any)
  description = "Role assignments for the load balancer"
  default     = {}
}

variable "diagnostic_settings" {
  type        = map(any)
  description = "Diagnostic settings for the load balancer"
  default     = {}
}

variable "tags" {
  type        = map(string)
  description = "Tags to apply to the load balancer"
  default     = {}
}
