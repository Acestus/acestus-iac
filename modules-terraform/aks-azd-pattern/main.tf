# Acestus AKS AZD Pattern Module - Terraform
# Wraps Azure Verified Modules to create a complete AKS environment
# Similar to the Bicep avm/ptn/azd/aks pattern

# ============================================================================
# AKS Cluster
# ============================================================================

module "aks" {
  source  = "Azure/avm-res-containerservice-managedcluster/azurerm"
  version = "~> 0.4"

  name                = var.aks_name
  resource_group_name = var.resource_group_name
  location            = var.location

  # Kubernetes version
  kubernetes_version = var.kubernetes_version

  # SKU tier
  sku_tier = var.sku_tier

  # Default node pool (system)
  default_node_pool = local.system_node_pool

  # Additional node pools
  node_pools = local.agent_node_pools

  # Network profile
  network_profile = {
    network_plugin      = var.network_plugin
    network_plugin_mode = var.network_plugin_mode
    network_policy      = var.network_policy
    load_balancer_sku   = var.load_balancer_sku
    outbound_type       = var.outbound_type
    service_cidr        = var.service_cidr != "" ? var.service_cidr : null
    dns_service_ip      = var.dns_service_ip != "" ? var.dns_service_ip : null
    pod_cidr            = var.pod_cidr != "" ? var.pod_cidr : null
  }

  # Identity
  managed_identities = {
    system_assigned = true
  }

  # Azure AD RBAC
  azure_active_directory_role_based_access_control = var.enable_azure_rbac ? {
    azure_rbac_enabled = true
    managed            = true
  } : null

  # Private cluster
  private_cluster_enabled             = var.enable_private_cluster
  private_cluster_public_fqdn_enabled = var.enable_private_cluster ? var.private_cluster_public_fqdn_enabled : false

  # Workload identity & OIDC
  oidc_issuer_enabled       = var.enable_oidc_issuer
  workload_identity_enabled = var.enable_workload_identity

  # Diagnostic settings for monitoring
  diagnostic_settings = var.monitoring_workspace_id != "" ? {
    main = {
      workspace_resource_id = var.monitoring_workspace_id
    }
  } : {}

  # Tags
  tags = var.tags
}

# ============================================================================
# Container Registry
# ============================================================================

module "acr" {
  source  = "Azure/avm-res-containerregistry-registry/azurerm"
  version = "~> 0.4"

  name                = var.container_registry_name
  resource_group_name = var.resource_group_name
  location            = var.location

  sku = var.acr_sku

  admin_enabled                 = var.acr_admin_enabled
  anonymous_pull_enabled        = var.acr_anonymous_pull_enabled
  public_network_access_enabled = var.acr_public_network_access_enabled

  zone_redundancy_enabled = var.acr_sku == "Premium" ? var.acr_zone_redundancy_enabled : false

  # Grant AKS kubelet identity ACR pull access
  role_assignments = {
    acrpull = {
      role_definition_id_or_name = "AcrPull"
      principal_id               = module.aks.kubelet_identity[0].object_id
    }
  }

  # Diagnostic settings for monitoring
  diagnostic_settings = var.monitoring_workspace_id != "" ? {
    main = {
      workspace_resource_id = var.monitoring_workspace_id
    }
  } : {}

  tags = var.tags
}

# ============================================================================
# Key Vault
# ============================================================================

module "key_vault" {
  source  = "Azure/avm-res-keyvault-vault/azurerm"
  version = "~> 0.9"

  name                = var.key_vault_name
  resource_group_name = var.resource_group_name
  location            = var.location
  tenant_id           = data.azurerm_client_config.current.tenant_id

  sku_name = "standard"

  purge_protection_enabled   = var.key_vault_enable_purge_protection
  soft_delete_retention_days = var.key_vault_soft_delete_retention_days

  public_network_access_enabled = var.key_vault_public_network_access_enabled
  enable_rbac_authorization     = true

  # Grant deploying principal access
  role_assignments = {
    deployer = {
      role_definition_id_or_name = "Key Vault Secrets Officer"
      principal_id               = var.principal_id != "" ? var.principal_id : data.azurerm_client_config.current.object_id
    }
    aks_secrets_user = {
      role_definition_id_or_name = "Key Vault Secrets User"
      principal_id               = module.aks.resource.identity[0].principal_id
    }
  }

  # Diagnostic settings for monitoring
  diagnostic_settings = var.monitoring_workspace_id != "" ? {
    main = {
      workspace_resource_id = var.monitoring_workspace_id
    }
  } : {}

  tags = var.tags
}

# ============================================================================
# Data Sources
# ============================================================================

data "azurerm_client_config" "current" {}

# ============================================================================
# Locals
# ============================================================================

locals {
  # Pool size to VM size mapping
  pool_size_map = {
    CostOptimised = "Standard_B4ms"
    Standard      = "Standard_D4s_v5"
    HighSpec      = "Standard_D8s_v5"
  }

  # System node pool configuration
  system_node_pool = merge(var.system_node_pool_config, {
    name                         = coalesce(try(var.system_node_pool_config.name, null), "system")
    vm_size                      = coalesce(try(var.system_node_pool_config.vm_size, null), lookup(local.pool_size_map, var.system_pool_size, "Standard_D4s_v5"))
    node_count                   = coalesce(try(var.system_node_pool_config.node_count, null), 3)
    min_count                    = coalesce(try(var.system_node_pool_config.min_count, null), 2)
    max_count                    = coalesce(try(var.system_node_pool_config.max_count, null), 5)
    enable_auto_scaling          = coalesce(try(var.system_node_pool_config.enable_auto_scaling, null), true)
    zones                        = coalesce(try(var.system_node_pool_config.zones, null), ["1", "2", "3"])
    only_critical_addons_enabled = coalesce(try(var.system_node_pool_config.only_critical_addons_enabled, null), true)
    os_disk_type                 = coalesce(try(var.system_node_pool_config.os_disk_type, null), "Managed")
    os_disk_size_gb              = coalesce(try(var.system_node_pool_config.os_disk_size_gb, null), 128)
  })

  # Agent node pools configuration
  agent_node_pools = var.agent_pool_size != "" ? {
    agents = merge(var.agent_node_pool_config, {
      name                = coalesce(try(var.agent_node_pool_config.name, null), "agents")
      vm_size             = coalesce(try(var.agent_node_pool_config.vm_size, null), lookup(local.pool_size_map, var.agent_pool_size, "Standard_D4s_v5"))
      node_count          = coalesce(try(var.agent_node_pool_config.node_count, null), 3)
      min_count           = coalesce(try(var.agent_node_pool_config.min_count, null), 1)
      max_count           = coalesce(try(var.agent_node_pool_config.max_count, null), 10)
      enable_auto_scaling = coalesce(try(var.agent_node_pool_config.enable_auto_scaling, null), true)
      zones               = coalesce(try(var.agent_node_pool_config.zones, null), ["1", "2", "3"])
      os_disk_type        = coalesce(try(var.agent_node_pool_config.os_disk_type, null), "Managed")
      os_disk_size_gb     = coalesce(try(var.agent_node_pool_config.os_disk_size_gb, null), 128)
    })
  } : var.custom_agent_node_pools
}
