# Acestus AKS Cluster Module Variables

variable "name" {
  type        = string
  description = "The name of the AKS cluster"
}

variable "resource_group_name" {
  type        = string
  description = "The name of the resource group"
}

variable "location" {
  type        = string
  description = "The Azure region for the AKS cluster"
}

variable "kubernetes_version" {
  type        = string
  description = "The Kubernetes version"
  default     = null
}

variable "sku_tier" {
  type        = string
  description = "The SKU tier (Free or Standard)"
  default     = "Standard"
}

variable "default_node_pool" {
  type        = any
  description = "Default node pool configuration"
  default = {
    name                         = "system"
    vm_size                      = "Standard_D4s_v5"
    node_count                   = 3
    min_count                    = 3
    max_count                    = 10
    enable_auto_scaling          = true
    zones                        = ["1", "2", "3"]
    only_critical_addons_enabled = true
    os_disk_type                 = "Ephemeral"
    os_disk_size_gb              = 128
  }
}

variable "node_pools" {
  type        = map(any)
  description = "Additional node pool configurations"
  default     = {}
}

variable "network_profile" {
  type        = any
  description = "Network profile configuration"
  default = {
    network_plugin      = "azure"
    network_plugin_mode = "overlay"
    network_policy      = "azure"
    load_balancer_sku   = "standard"
    outbound_type       = "loadBalancer"
  }
}

variable "managed_identities" {
  type        = any
  description = "Managed identity configuration"
  default = {
    system_assigned = true
  }
}

variable "azure_active_directory_role_based_access_control" {
  type        = any
  description = "Azure AD RBAC configuration"
  default = {
    azure_rbac_enabled = true
    managed            = true
  }
}

variable "private_cluster_enabled" {
  type        = bool
  description = "Enable private cluster"
  default     = true
}

variable "private_cluster_public_fqdn_enabled" {
  type        = bool
  description = "Enable public FQDN for private cluster"
  default     = false
}

variable "private_dns_zone_id" {
  type        = string
  description = "Private DNS zone ID"
  default     = null
}

variable "auto_scaler_profile" {
  type        = any
  description = "Cluster autoscaler profile"
  default     = null
}

variable "maintenance_window" {
  type        = any
  description = "Maintenance window configuration"
  default     = null
}

variable "key_vault_secrets_provider" {
  type        = any
  description = "Key Vault secrets provider configuration"
  default = {
    secret_rotation_enabled  = true
    secret_rotation_interval = "2m"
  }
}

variable "oidc_issuer_enabled" {
  type        = bool
  description = "Enable OIDC issuer"
  default     = true
}

variable "workload_identity_enabled" {
  type        = bool
  description = "Enable workload identity"
  default     = true
}

variable "azure_policy_enabled" {
  type        = bool
  description = "Enable Azure Policy"
  default     = true
}

variable "microsoft_defender" {
  type        = any
  description = "Microsoft Defender configuration"
  default     = null
}

variable "role_assignments" {
  type        = map(any)
  description = "Role assignments for the AKS cluster"
  default     = {}
}

variable "diagnostic_settings" {
  type        = map(any)
  description = "Diagnostic settings for the AKS cluster"
  default     = {}
}

variable "tags" {
  type        = map(string)
  description = "Tags to apply to the AKS cluster"
  default     = {}
}
