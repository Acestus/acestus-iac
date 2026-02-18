# Acestus Application Gateway Module Variables

variable "name" {
  type        = string
  description = "The name of the application gateway"
}

variable "resource_group_name" {
  type        = string
  description = "The name of the resource group"
}

variable "location" {
  type        = string
  description = "The Azure region for the application gateway"
}

variable "sku_name" {
  type        = string
  description = "The SKU name of the application gateway (WAF_v2 recommended for security)"
  default     = "WAF_v2"
  validation {
    condition     = contains(["Standard_Small", "Standard_Medium", "Standard_Large", "Standard_v2", "WAF_Medium", "WAF_Large", "WAF_v2"], var.sku_name)
    error_message = "SKU name must be a valid Application Gateway SKU."
  }
}

variable "sku_tier" {
  type        = string
  description = "The SKU tier of the application gateway"
  default     = "WAF_v2"
  validation {
    condition     = contains(["Standard", "Standard_v2", "WAF", "WAF_v2"], var.sku_tier)
    error_message = "SKU tier must be 'Standard', 'Standard_v2', 'WAF', or 'WAF_v2'."
  }
}

variable "capacity" {
  type        = number
  description = "The capacity (instance count) of the application gateway"
  default     = 2
  validation {
    condition     = var.capacity >= 1 && var.capacity <= 125
    error_message = "Capacity must be between 1 and 125."
  }
}

variable "zones" {
  type        = list(string)
  description = "Availability zones for the application gateway"
  default     = null
}

variable "gateway_ip_configuration" {
  type = map(object({
    name      = string
    subnet_id = string
  }))
  description = "Gateway IP configuration (subnet must be dedicated to Application Gateway)"
  default     = {}
}

variable "frontend_ip_configuration" {
  type = map(object({
    name                            = string
    public_ip_address_id            = optional(string)
    private_ip_address              = optional(string)
    private_ip_address_allocation   = optional(string, "Dynamic")
    subnet_id                       = optional(string)
    private_link_configuration_name = optional(string)
  }))
  description = "Frontend IP configuration for the application gateway"
  default     = {}
}

variable "frontend_ports" {
  type = map(object({
    name = string
    port = number
  }))
  description = "Frontend ports for the application gateway"
  default     = {}
}

variable "backend_address_pools" {
  type = map(object({
    name         = string
    fqdns        = optional(list(string))
    ip_addresses = optional(list(string))
  }))
  description = "Backend address pools for the application gateway"
  default     = {}
}

variable "backend_http_settings" {
  type = map(object({
    name                                = string
    port                                = number
    protocol                            = string
    cookie_based_affinity               = optional(string, "Disabled")
    affinity_cookie_name                = optional(string)
    path                                = optional(string)
    probe_name                          = optional(string)
    request_timeout                     = optional(number, 30)
    host_name                           = optional(string)
    pick_host_name_from_backend_address = optional(bool, false)
    trusted_root_certificate_names      = optional(list(string))
    connection_draining = optional(object({
      enabled           = bool
      drain_timeout_sec = number
    }))
    authentication_certificate = optional(object({
      name = string
    }))
  }))
  description = "Backend HTTP settings for the application gateway"
  default     = {}
}

variable "http_listeners" {
  type = map(object({
    name                           = string
    frontend_ip_configuration_name = string
    frontend_port_name             = string
    protocol                       = string
    host_name                      = optional(string)
    host_names                     = optional(list(string))
    ssl_certificate_name           = optional(string)
    ssl_profile_name               = optional(string)
    require_sni                    = optional(bool, false)
    firewall_policy_id             = optional(string)
    custom_error_configuration = optional(list(object({
      status_code           = string
      custom_error_page_url = string
    })))
  }))
  description = "HTTP listeners for the application gateway"
  default     = {}
}

variable "request_routing_rules" {
  type = map(object({
    name                        = string
    rule_type                   = string
    priority                    = number
    http_listener_name          = string
    backend_address_pool_name   = optional(string)
    backend_http_settings_name  = optional(string)
    redirect_configuration_name = optional(string)
    rewrite_rule_set_name       = optional(string)
    url_path_map_name           = optional(string)
  }))
  description = "Request routing rules for the application gateway"
  default     = {}
}

variable "waf_configuration" {
  type = object({
    enabled                  = bool
    firewall_mode            = optional(string, "Prevention")
    rule_set_type            = optional(string, "OWASP")
    rule_set_version         = optional(string, "3.2")
    file_upload_limit_mb     = optional(number, 100)
    request_body_check       = optional(bool, true)
    max_request_body_size_kb = optional(number, 128)
    disabled_rule_group = optional(list(object({
      rule_group_name = string
      rules           = optional(list(string))
    })))
    exclusion = optional(list(object({
      match_variable          = string
      selector_match_operator = optional(string)
      selector                = optional(string)
    })))
  })
  description = "WAF configuration for the application gateway (Acestus security - enabled in Prevention mode by default)"
  default = {
    enabled          = true
    firewall_mode    = "Prevention"
    rule_set_type    = "OWASP"
    rule_set_version = "3.2"
  }
}

variable "ssl_certificates" {
  type = map(object({
    name                = string
    data                = optional(string)
    password            = optional(string)
    key_vault_secret_id = optional(string)
  }))
  description = "SSL certificates for the application gateway"
  default     = {}
  sensitive   = true
}

variable "ssl_policy" {
  type = object({
    policy_type          = optional(string, "Predefined")
    policy_name          = optional(string, "AppGwSslPolicy20220101S")
    min_protocol_version = optional(string)
    cipher_suites        = optional(list(string))
    disabled_protocols   = optional(list(string))
  })
  description = "SSL policy for the application gateway (Acestus security - uses secure policy by default)"
  default = {
    policy_type = "Predefined"
    policy_name = "AppGwSslPolicy20220101S"
  }
}

variable "managed_identities" {
  type = object({
    system_assigned            = optional(bool, false)
    user_assigned_resource_ids = optional(set(string), [])
  })
  description = "Managed identities for the application gateway"
  default     = {}
}

variable "role_assignments" {
  type        = map(any)
  description = "Role assignments for the application gateway"
  default     = {}
}

variable "diagnostic_settings" {
  type        = map(any)
  description = "Diagnostic settings for the application gateway"
  default     = {}
}

variable "tags" {
  type        = map(string)
  description = "Tags to apply to the application gateway"
  default     = {}
}
