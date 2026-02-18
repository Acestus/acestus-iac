# Acestus AKS AZD Pattern Module Variables

# ============================================================================
# Required Variables
# ============================================================================

variable "aks_name" {
  type        = string
  description = "The name of the AKS cluster"
}

variable "container_registry_name" {
  type        = string
  description = "The name of the Container Registry (must be globally unique, alphanumeric)"

  validation {
    condition     = can(regex("^[a-zA-Z0-9]{5,50}$", var.container_registry_name))
    error_message = "Container Registry name must be 5-50 alphanumeric characters."
  }
}

variable "key_vault_name" {
  type        = string
  description = "The name of the Key Vault"

  validation {
    condition     = can(regex("^[a-zA-Z][a-zA-Z0-9-]{1,22}[a-zA-Z0-9]$", var.key_vault_name))
    error_message = "Key Vault name must be 3-24 characters, start with a letter, and contain only alphanumeric characters and hyphens."
  }
}

variable "resource_group_name" {
  type        = string
  description = "The name of the resource group"
}

variable "location" {
  type        = string
  description = "The Azure region for resources"
}

# ============================================================================
# Monitoring
# ============================================================================

variable "monitoring_workspace_id" {
  type        = string
  description = "Resource ID of existing Log Analytics workspace for monitoring"
  default     = ""
}

variable "principal_id" {
  type        = string
  description = "Principal ID for Key Vault access (defaults to current user/service principal)"
  default     = ""
}

# ============================================================================
# Kubernetes Configuration
# ============================================================================

variable "kubernetes_version" {
  type        = string
  description = "The Kubernetes version"
  default     = "1.30"
}

variable "sku_tier" {
  type        = string
  description = "The SKU tier (Free, Standard, or Premium)"
  default     = "Free"

  validation {
    condition     = contains(["Free", "Standard", "Premium"], var.sku_tier)
    error_message = "SKU tier must be Free, Standard, or Premium."
  }
}

variable "system_pool_size" {
  type        = string
  description = "System pool VM size preset: CostOptimised, Standard, or HighSpec"
  default     = "Standard"

  validation {
    condition     = contains(["CostOptimised", "Standard", "HighSpec"], var.system_pool_size)
    error_message = "System pool size must be CostOptimised, Standard, or HighSpec."
  }
}

variable "agent_pool_size" {
  type        = string
  description = "Agent pool VM size preset: CostOptimised, Standard, HighSpec, or empty for no agent pool"
  default     = ""

  validation {
    condition     = var.agent_pool_size == "" || contains(["CostOptimised", "Standard", "HighSpec"], var.agent_pool_size)
    error_message = "Agent pool size must be empty, CostOptimised, Standard, or HighSpec."
  }
}

variable "system_node_pool_config" {
  type        = any
  description = "Custom system node pool configuration (overrides system_pool_size defaults)"
  default     = {}
}

variable "agent_node_pool_config" {
  type        = any
  description = "Custom agent node pool configuration (overrides agent_pool_size defaults)"
  default     = {}
}

variable "custom_agent_node_pools" {
  type        = map(any)
  description = "Custom agent node pools (used when agent_pool_size is empty)"
  default     = {}
}

# ============================================================================
# Network Configuration
# ============================================================================

variable "network_plugin" {
  type        = string
  description = "Network plugin (azure or kubenet)"
  default     = "azure"

  validation {
    condition     = contains(["azure", "kubenet"], var.network_plugin)
    error_message = "Network plugin must be azure or kubenet."
  }
}

variable "network_plugin_mode" {
  type        = string
  description = "Network plugin mode (overlay or empty)"
  default     = "overlay"
}

variable "network_policy" {
  type        = string
  description = "Network policy (azure, calico, or cilium)"
  default     = "azure"
}

variable "load_balancer_sku" {
  type        = string
  description = "Load balancer SKU (basic or standard)"
  default     = "standard"
}

variable "outbound_type" {
  type        = string
  description = "Outbound traffic type"
  default     = "loadBalancer"
}

variable "service_cidr" {
  type        = string
  description = "Service CIDR for Kubernetes services"
  default     = ""
}

variable "dns_service_ip" {
  type        = string
  description = "DNS service IP address (must be within service_cidr)"
  default     = ""
}

variable "pod_cidr" {
  type        = string
  description = "Pod CIDR (required for kubenet)"
  default     = ""
}

# ============================================================================
# Security Configuration
# ============================================================================

variable "enable_azure_rbac" {
  type        = bool
  description = "Enable Azure RBAC for Kubernetes authorization"
  default     = true
}

variable "enable_private_cluster" {
  type        = bool
  description = "Enable private cluster"
  default     = false
}

variable "private_cluster_public_fqdn_enabled" {
  type        = bool
  description = "Enable public FQDN for private cluster"
  default     = false
}

variable "enable_oidc_issuer" {
  type        = bool
  description = "Enable OIDC issuer for workload identity"
  default     = true
}

variable "enable_workload_identity" {
  type        = bool
  description = "Enable workload identity"
  default     = true
}

# ============================================================================
# Container Registry Configuration
# ============================================================================

variable "acr_sku" {
  type        = string
  description = "Container Registry SKU (Basic, Standard, or Premium)"
  default     = "Basic"

  validation {
    condition     = contains(["Basic", "Standard", "Premium"], var.acr_sku)
    error_message = "ACR SKU must be Basic, Standard, or Premium."
  }
}

variable "acr_admin_enabled" {
  type        = bool
  description = "Enable admin user for Container Registry"
  default     = false
}

variable "acr_anonymous_pull_enabled" {
  type        = bool
  description = "Enable anonymous pull for Container Registry"
  default     = false
}

variable "acr_public_network_access_enabled" {
  type        = bool
  description = "Enable public network access for Container Registry"
  default     = true
}

variable "acr_zone_redundancy_enabled" {
  type        = bool
  description = "Enable zone redundancy for Container Registry (Premium SKU only)"
  default     = false
}

# ============================================================================
# Key Vault Configuration
# ============================================================================

variable "key_vault_enable_purge_protection" {
  type        = bool
  description = "Enable purge protection for Key Vault"
  default     = true
}

variable "key_vault_soft_delete_retention_days" {
  type        = number
  description = "Soft delete retention days for Key Vault"
  default     = 90
}

variable "key_vault_public_network_access_enabled" {
  type        = bool
  description = "Enable public network access for Key Vault"
  default     = true
}

# ============================================================================
# Tags
# ============================================================================

variable "tags" {
  type        = map(string)
  description = "Tags to apply to all resources"
  default     = {}
}
