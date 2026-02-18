# AKS Stack - Terraform
# Deploys AKS cluster with ACR, Key Vault, and monitoring
# Using Acestus AKS AZD Pattern module (wrapper for Azure Verified Modules)

# ============================================================================
# Resource Group
# ============================================================================

resource "azurerm_resource_group" "main" {
  name     = "rg-${var.project_name}-${var.environment}-${var.caf_location}-${var.instance_number}"
  location = var.location

  tags = local.tags
}

# ============================================================================
# AKS Stack using Acestus AKS AZD Pattern Module
# ============================================================================

module "aks_stack" {
  # Use ACR module reference after publishing
  # source = "oci://acrskpmgtcrdevusw2001.azurecr.io/terraform/modules/aks-azd-pattern"
  # version = "1.0.0"
  
  # For local development, use relative path
  source = "../../modules-terraform/aks-azd-pattern"

  # Required parameters
  aks_name                = local.aks_cluster_name
  container_registry_name = local.container_registry_name
  key_vault_name          = local.key_vault_name
  resource_group_name     = azurerm_resource_group.main.name
  location                = azurerm_resource_group.main.location

  # Monitoring
  monitoring_workspace_id = var.monitoring_workspace_id
  principal_id            = var.principal_id

  # Kubernetes configuration
  kubernetes_version = var.kubernetes_version
  sku_tier           = var.sku_tier
  system_pool_size   = var.system_pool_size
  agent_pool_size    = var.agent_pool_size

  # Network configuration
  network_plugin      = "azure"
  network_plugin_mode = "overlay"
  network_policy      = "azure"
  load_balancer_sku   = "standard"

  # Security configuration
  enable_azure_rbac        = true
  enable_oidc_issuer       = true
  enable_workload_identity = true

  # Tags
  tags = local.tags
}

# ============================================================================
# Locals
# ============================================================================

locals {
  # Resource naming
  aks_cluster_name        = "aks-${var.project_name}-${var.environment}-${var.caf_location}-${var.instance_number}"
  container_registry_name = "acr${var.project_name}${var.environment}${var.caf_location}${var.instance_number}"
  key_vault_name          = "kv-${var.project_name}-${var.environment}-${var.caf_location}"

  # Common tags
  tags = merge(var.tags, {
    Environment = var.environment
    Project     = var.project_name
    ManagedBy   = "terraform"
    Stack       = "rg-newaks-usw2"
  })
}
