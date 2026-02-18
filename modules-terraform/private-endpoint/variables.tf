# Acestus Private Endpoint Module Variables

variable "name" {
  type        = string
  description = "The name of the private endpoint"
}

variable "resource_group_name" {
  type        = string
  description = "The name of the resource group"
}

variable "location" {
  type        = string
  description = "The Azure region for the private endpoint"
}

variable "subnet_id" {
  type        = string
  description = "The resource ID of the subnet where the private endpoint will be created"
}

variable "private_connection_resource_id" {
  type        = string
  description = "The resource ID of the private link service or Azure resource to connect to"
}

variable "subresource_names" {
  type        = list(string)
  description = "The list of subresource names (group IDs) for the private endpoint connection"
  default     = []
}

variable "is_manual_connection" {
  type        = bool
  description = "Whether the connection is manual and requires approval"
  default     = false
}

variable "private_dns_zone_group" {
  type = object({
    name                 = optional(string)
    private_dns_zone_ids = list(string)
  })
  description = "Private DNS zone group configuration for automatic DNS registration"
  default     = null
}

variable "custom_network_interface_name" {
  type        = string
  description = "Custom name for the network interface associated with the private endpoint"
  default     = null
}

variable "role_assignments" {
  type        = map(any)
  description = "Role assignments for the private endpoint"
  default     = {}
}

variable "tags" {
  type        = map(string)
  description = "Tags to apply to the private endpoint"
  default     = {}
}
