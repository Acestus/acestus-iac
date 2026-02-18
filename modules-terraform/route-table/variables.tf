# Acestus Route Table Module Variables

variable "name" {
  type        = string
  description = "The name of the route table"
}

variable "resource_group_name" {
  type        = string
  description = "The name of the resource group"
}

variable "location" {
  type        = string
  description = "The Azure region for the route table"
}

variable "disable_bgp_route_propagation" {
  type        = bool
  description = "Disable BGP route propagation (set to true for hub-spoke scenarios)"
  default     = false
}

variable "routes" {
  type = map(object({
    name                   = string
    address_prefix         = string
    next_hop_type          = string
    next_hop_in_ip_address = optional(string)
  }))
  description = "Map of routes to create in the route table"
  default     = {}
  validation {
    condition = alltrue([
      for route in values(var.routes) :
      contains(["VirtualNetworkGateway", "VnetLocal", "Internet", "VirtualAppliance", "None"], route.next_hop_type)
    ])
    error_message = "next_hop_type must be one of: VirtualNetworkGateway, VnetLocal, Internet, VirtualAppliance, None."
  }
}

variable "role_assignments" {
  type        = map(any)
  description = "Role assignments for the route table"
  default     = {}
}

variable "tags" {
  type        = map(string)
  description = "Tags to apply to the route table"
  default     = {}
}
