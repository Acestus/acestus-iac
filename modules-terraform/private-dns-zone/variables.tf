# Acestus Private DNS Zone Module Variables

variable "name" {
  type        = string
  description = "The name of the private DNS zone (e.g., privatelink.blob.core.windows.net)"
}

variable "resource_group_name" {
  type        = string
  description = "The name of the resource group"
}

variable "virtual_network_links" {
  type = map(object({
    vnetlinkname     = optional(string)
    vnetid           = string
    autoregistration = optional(bool, false)
    tags             = optional(map(string), {})
  }))
  description = "Map of virtual network links to associate with the private DNS zone"
  default     = {}
}

variable "a_records" {
  type = map(object({
    name    = string
    ttl     = optional(number, 3600)
    records = list(string)
    tags    = optional(map(string), {})
  }))
  description = "Map of A records to create in the private DNS zone"
  default     = {}
}

variable "aaaa_records" {
  type = map(object({
    name    = string
    ttl     = optional(number, 3600)
    records = list(string)
    tags    = optional(map(string), {})
  }))
  description = "Map of AAAA records to create in the private DNS zone"
  default     = {}
}

variable "cname_records" {
  type = map(object({
    name   = string
    ttl    = optional(number, 3600)
    record = string
    tags   = optional(map(string), {})
  }))
  description = "Map of CNAME records to create in the private DNS zone"
  default     = {}
}

variable "mx_records" {
  type = map(object({
    name = string
    ttl  = optional(number, 3600)
    records = list(object({
      preference = number
      exchange   = string
    }))
    tags = optional(map(string), {})
  }))
  description = "Map of MX records to create in the private DNS zone"
  default     = {}
}

variable "ptr_records" {
  type = map(object({
    name    = string
    ttl     = optional(number, 3600)
    records = list(string)
    tags    = optional(map(string), {})
  }))
  description = "Map of PTR records to create in the private DNS zone"
  default     = {}
}

variable "srv_records" {
  type = map(object({
    name = string
    ttl  = optional(number, 3600)
    records = list(object({
      priority = number
      weight   = number
      port     = number
      target   = string
    }))
    tags = optional(map(string), {})
  }))
  description = "Map of SRV records to create in the private DNS zone"
  default     = {}
}

variable "txt_records" {
  type = map(object({
    name = string
    ttl  = optional(number, 3600)
    records = list(object({
      value = string
    }))
    tags = optional(map(string), {})
  }))
  description = "Map of TXT records to create in the private DNS zone"
  default     = {}
}

variable "soa_record" {
  type = object({
    email        = string
    expire_time  = optional(number, 2419200)
    minimum_ttl  = optional(number, 10)
    refresh_time = optional(number, 3600)
    retry_time   = optional(number, 300)
    ttl          = optional(number, 3600)
    tags         = optional(map(string), {})
  })
  description = "SOA record configuration for the private DNS zone"
  default     = null
}

variable "role_assignments" {
  type        = map(any)
  description = "Role assignments for the private DNS zone"
  default     = {}
}

variable "tags" {
  type        = map(string)
  description = "Tags to apply to the private DNS zone"
  default     = {}
}
