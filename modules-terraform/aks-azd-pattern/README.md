# Acestus AKS AZD Pattern Module

Terraform wrapper module that combines Azure Verified Modules (AVM) to create a complete AKS environment, similar to the Bicep `avm/ptn/azd/aks` pattern.

## Overview

This module deploys:
- **AKS Managed Cluster** - Kubernetes cluster with configurable node pools
- **Azure Container Registry** - For container image storage (with AcrPull access granted to AKS)
- **Azure Key Vault** - For secrets management (with RBAC access configured)
- **Monitoring Integration** - Connected to Log Analytics workspace

## Usage

### Basic Example

```hcl
module "aks_stack" {
  source  = "oci://acracemgtcrdevusw2001.azurecr.io/terraform/modules/aks-azd-pattern"
  version = "1.0.0"

  aks_name                = "aks-myapp-dev-usw2-001"
  container_registry_name = "acrmyappdevusw2001"
  key_vault_name          = "kv-myapp-dev-usw2"
  resource_group_name     = azurerm_resource_group.main.name
  location                = azurerm_resource_group.main.location

  monitoring_workspace_id = data.azurerm_log_analytics_workspace.main.id

  tags = {
    Environment = "dev"
    Project     = "myapp"
  }
}
```

### Production Example

```hcl
module "aks_stack" {
  source  = "oci://acracemgtcrprdusw2001.azurecr.io/terraform/modules/aks-azd-pattern"
  version = "1.0.0"

  aks_name                = "aks-myapp-prd-usw2-001"
  container_registry_name = "acrmyappprdusw2001"
  key_vault_name          = "kv-myapp-prd-usw2"
  resource_group_name     = azurerm_resource_group.main.name
  location                = azurerm_resource_group.main.location

  monitoring_workspace_id = data.azurerm_log_analytics_workspace.main.id

  # Kubernetes configuration
  kubernetes_version = "1.30"
  sku_tier           = "Standard"
  system_pool_size   = "Standard"
  agent_pool_size    = "HighSpec"

  # Security
  enable_private_cluster   = true
  enable_azure_rbac        = true
  enable_workload_identity = true

  # ACR
  acr_sku = "Premium"

  tags = {
    Environment = "prd"
    Criticality = "high"
  }
}
```

## Requirements

| Name | Version |
|------|---------|
| terraform | >= 1.5.0 |
| azurerm | >= 3.71.0 |

## Providers

| Name | Version |
|------|---------|
| azurerm | >= 3.71.0 |

## Inputs

### Required

| Name | Description | Type |
|------|-------------|------|
| `aks_name` | The name of the AKS cluster | `string` |
| `container_registry_name` | The name of the Container Registry (globally unique) | `string` |
| `key_vault_name` | The name of the Key Vault | `string` |
| `resource_group_name` | The name of the resource group | `string` |
| `location` | The Azure region for resources | `string` |

### Kubernetes Configuration

| Name | Description | Type | Default |
|------|-------------|------|---------|
| `kubernetes_version` | The Kubernetes version | `string` | `"1.30"` |
| `sku_tier` | SKU tier (Free, Standard, Premium) | `string` | `"Free"` |
| `system_pool_size` | System pool preset (CostOptimised, Standard, HighSpec) | `string` | `"Standard"` |
| `agent_pool_size` | Agent pool preset (empty for none) | `string` | `""` |

### Pool Size Mappings

| Size | VM SKU | Description |
|------|--------|-------------|
| `CostOptimised` | Standard_B4ms | 4 vCPU, 16 GB RAM - Dev/Test |
| `Standard` | Standard_D4s_v5 | 4 vCPU, 16 GB RAM - General |
| `HighSpec` | Standard_D8s_v5 | 8 vCPU, 32 GB RAM - Production |

### Network Configuration

| Name | Description | Type | Default |
|------|-------------|------|---------|
| `network_plugin` | Network plugin (azure, kubenet) | `string` | `"azure"` |
| `network_plugin_mode` | Plugin mode (overlay) | `string` | `"overlay"` |
| `network_policy` | Network policy | `string` | `"azure"` |
| `load_balancer_sku` | Load balancer SKU | `string` | `"standard"` |

### Security Configuration

| Name | Description | Type | Default |
|------|-------------|------|---------|
| `enable_azure_rbac` | Enable Azure RBAC for K8s | `bool` | `true` |
| `enable_private_cluster` | Enable private cluster | `bool` | `false` |
| `enable_oidc_issuer` | Enable OIDC issuer | `bool` | `true` |
| `enable_workload_identity` | Enable workload identity | `bool` | `true` |

### Container Registry Configuration

| Name | Description | Type | Default |
|------|-------------|------|---------|
| `acr_sku` | ACR SKU (Basic, Standard, Premium) | `string` | `"Basic"` |
| `acr_admin_enabled` | Enable admin user | `bool` | `false` |
| `acr_public_network_access_enabled` | Enable public access | `bool` | `true` |

### Key Vault Configuration

| Name | Description | Type | Default |
|------|-------------|------|---------|
| `key_vault_enable_purge_protection` | Enable purge protection | `bool` | `true` |
| `key_vault_soft_delete_retention_days` | Soft delete retention | `number` | `90` |

## Outputs

| Name | Description |
|------|-------------|
| `aks_name` | The name of the AKS cluster |
| `aks_resource_id` | The resource ID of the AKS cluster |
| `aks_fqdn` | The FQDN of the AKS cluster |
| `aks_oidc_issuer_url` | The OIDC issuer URL |
| `aks_identity_principal_id` | The AKS managed identity principal ID |
| `acr_name` | The name of the Container Registry |
| `acr_login_server` | The ACR login server |
| `key_vault_name` | The name of the Key Vault |
| `key_vault_uri` | The Key Vault URI |

## Underlying AVM Modules

This wrapper uses:
- `Azure/avm-res-containerservice-managedcluster/azurerm` ~> 0.4
- `Azure/avm-res-containerregistry-registry/azurerm` ~> 0.4
- `Azure/avm-res-keyvault-vault/azurerm` ~> 0.9

## Version History

| Version | Date | Description |
|---------|------|-------------|
| v1.0.0 | 2024 | Initial release with AKS, ACR, Key Vault |
