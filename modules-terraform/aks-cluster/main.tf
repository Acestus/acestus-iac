# Acestus AKS Cluster Module - AVM Wrapper
# Wraps Azure Verified Module: Azure/avm-res-containerservice-managedcluster/azurerm

module "aks" {
  source  = "Azure/avm-res-containerservice-managedcluster/azurerm"
  version = "~> 0.4"

  name                = var.name
  resource_group_name = var.resource_group_name
  location            = var.location

  # Kubernetes version
  kubernetes_version = var.kubernetes_version

  # SKU tier
  sku_tier = var.sku_tier

  # Default node pool
  default_node_pool = var.default_node_pool

  # Additional node pools
  node_pools = var.node_pools

  # Network profile
  network_profile = var.network_profile

  # Identity
  managed_identities = var.managed_identities

  # Azure AD integration
  azure_active_directory_role_based_access_control = var.azure_active_directory_role_based_access_control

  # Private cluster
  private_cluster_enabled             = var.private_cluster_enabled
  private_cluster_public_fqdn_enabled = var.private_cluster_public_fqdn_enabled
  private_dns_zone_id                 = var.private_dns_zone_id

  # Auto-scaler profile
  auto_scaler_profile = var.auto_scaler_profile

  # Maintenance window
  maintenance_window = var.maintenance_window

  # Key vault secrets provider
  key_vault_secrets_provider = var.key_vault_secrets_provider

  # Workload identity
  oidc_issuer_enabled       = var.oidc_issuer_enabled
  workload_identity_enabled = var.workload_identity_enabled

  # Azure Policy
  azure_policy_enabled = var.azure_policy_enabled

  # Defender
  microsoft_defender = var.microsoft_defender

  # Role assignments
  role_assignments = var.role_assignments

  # Diagnostic settings
  diagnostic_settings = var.diagnostic_settings

  # Tags
  tags = var.tags
}
