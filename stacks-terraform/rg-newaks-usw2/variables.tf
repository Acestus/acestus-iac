# AKS Stack - Variables

# ============================================================================
# Naming Variables
# ============================================================================

variable "project_name" {
  type        = string
  description = "The name of the project, used for naming resources"
}

variable "environment" {
  type        = string
  description = "The environment name (dev, stg, prd)"

  validation {
    condition     = contains(["dev", "stg", "prd"], var.environment)
    error_message = "Environment must be dev, stg, or prd."
  }
}

variable "caf_location" {
  type        = string
  description = "The Cloud Adoption Framework location abbreviation (e.g., sea)"
}

variable "instance_number" {
  type        = string
  description = "The instance number for unique naming"
  default     = "001"
}

variable "location" {
  type        = string
  description = "The Azure region for resources"
  default     = "West US 2"
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
  default     = "CostOptimised"

  validation {
    condition     = contains(["CostOptimised", "Standard", "HighSpec"], var.system_pool_size)
    error_message = "System pool size must be CostOptimised, Standard, or HighSpec."
  }
}

variable "agent_pool_size" {
  type        = string
  description = "Agent pool VM size preset: CostOptimised, Standard, HighSpec, or empty for no agent pool"
  default     = ""
}

# ============================================================================
# Monitoring
# ============================================================================

variable "monitoring_workspace_id" {
  type        = string
  description = "Resource ID of existing Log Analytics workspace for monitoring"
}

variable "principal_id" {
  type        = string
  description = "Principal ID for Key Vault access (deploying user or service principal)"
  default     = ""
}

# ============================================================================
# Tags
# ============================================================================

variable "tags" {
  type        = map(string)
  description = "Additional tags to apply to all resources"
  default     = {}
}
