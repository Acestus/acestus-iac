# Acestus AKS AZD Pattern Module

Wrapper module for the Azure Verified Modules (AVM) `avm/ptn/azd/aks` pattern, providing Acestus-standard defaults and naming conventions.

## Overview

This module wraps the AVM AKS pattern to deploy a complete AKS environment including:
- **AKS Managed Cluster** - Kubernetes cluster with configurable node pools
- **Azure Container Registry** - For container image storage
- **Azure Key Vault** - For secrets management
- **Monitoring Integration** - Connected to Log Analytics workspace

## Usage

### Basic Example

```bicep
module aksStack 'br:acracemgtcrprdwus3001.azurecr.io/bicep/modules/aks-azd-pattern:v1.0.0' = {
  name: 'aks-deployment'
  params: {
    name: 'aks-myapp-dev-wus3-001'
    location: 'westus2'
    containerRegistryName: 'acrmyappdevwus3001'
    keyVaultName: 'kv-myapp-dev-wus3'
    monitoringWorkspaceResourceId: '/subscriptions/.../resourceGroups/.../providers/Microsoft.OperationalInsights/workspaces/...'
    principalId: '00000000-0000-0000-0000-000000000000'
    tags: {
      Environment: 'dev'
      Project: 'myapp'
    }
  }
}
```

### Production Example with Custom Pools

```bicep
module aksStack 'br:acracemgtcrprdwus3001.azurecr.io/bicep/modules/aks-azd-pattern:v1.0.0' = {
  name: 'aks-deployment'
  params: {
    name: 'aks-myapp-prd-wus3-001'
    location: 'westus2'
    containerRegistryName: 'acrmyappprdwus3001'
    keyVaultName: 'kv-myapp-prd-wus3'
    monitoringWorkspaceResourceId: logAnalyticsWorkspace.id
    principalId: servicePrincipal.objectId
    
    // Kubernetes configuration
    kubernetesVersion: '1.30'
    skuTier: 'Standard'
    systemPoolSize: 'Standard'
    agentPoolSize: 'HighSpec'
    
    // Security
    enablePrivateCluster: true
    enableRbacAuthorization: true
    enableWorkloadIdentity: true
    
    // ACR
    acrSku: 'Premium'
    
    // Key Vault
    keyVaultEnablePurgeProtection: true
    
    tags: {
      Environment: 'prd'
      Project: 'myapp'
    }
  }
}
```

## Parameters

### Required Parameters

| Parameter | Type | Description |
|-----------|------|-------------|
| `name` | string | The name of the AKS cluster |
| `containerRegistryName` | string | Name for the Container Registry (must be globally unique) |
| `keyVaultName` | string | Name for the Key Vault |
| `monitoringWorkspaceResourceId` | string | Resource ID of existing Log Analytics workspace |
| `principalId` | string | Principal ID for Key Vault access |

### Kubernetes Configuration

| Parameter | Type | Default | Description |
|-----------|------|---------|-------------|
| `kubernetesVersion` | string | `'1.30'` | Kubernetes version |
| `skuTier` | string | `'Free'` | SKU tier: Free, Standard, Premium |
| `systemPoolSize` | string | `'Standard'` | System pool size: CostOptimised, Standard, HighSpec |
| `agentPoolSize` | string | `''` | Agent pool size (empty for no agent pool) |

### Pool Size Mappings

| Size | VM SKU | Description |
|------|--------|-------------|
| `CostOptimised` | Standard_B4ms | 4 vCPU, 16 GB RAM - Dev/Test workloads |
| `Standard` | Standard_D4s_v5 | 4 vCPU, 16 GB RAM - General purpose |
| `HighSpec` | Standard_D8s_v5 | 8 vCPU, 32 GB RAM - Production workloads |

### Network Configuration

| Parameter | Type | Default | Description |
|-----------|------|---------|-------------|
| `networkDataplane` | string | `'azure'` | Network dataplane: azure, cilium |
| `networkPlugin` | string | `'azure'` | Network plugin: azure, kubenet |
| `networkPolicy` | string | `'azure'` | Network policy: azure, calico |
| `loadBalancerSku` | string | `'standard'` | Load balancer SKU: basic, standard |
| `serviceCidr` | string | `''` | Service CIDR for Kubernetes services |
| `dnsServiceIP` | string | `''` | DNS service IP address |
| `podCidr` | string | `''` | Pod CIDR for Kubernetes pods |
| `publicNetworkAccess` | string | `'Enabled'` | Enable public network access |

### Security Configuration

| Parameter | Type | Default | Description |
|-----------|------|---------|-------------|
| `enableRbacAuthorization` | bool | `true` | Enable Azure RBAC for Kubernetes |
| `enableAzureRbac` | bool | `true` | Enable Azure RBAC |
| `disableLocalAccounts` | bool | `true` | Disable local accounts |
| `enableKeyvaultSecretsProvider` | bool | `false` | Enable Key Vault secrets provider |

### Container Registry Configuration

| Parameter | Type | Default | Description |
|-----------|------|---------|-------------|
| `acrSku` | string | `'Basic'` | ACR SKU: Basic, Standard, Premium |

### Key Vault Configuration

| Parameter | Type | Default | Description |
|-----------|------|---------|-------------|
| `enablePurgeProtection` | bool | `true` | Enable purge protection |
| `enableVaultForDeployment` | bool | `true` | Enable vault for deployment |
| `enableVaultForTemplateDeployment` | bool | `true` | Enable vault for template deployment |

## Outputs

| Output | Type | Description |
|--------|------|-------------|
| `managedClusterName` | string | AKS cluster name |
| `managedClusterResourceId` | string | AKS cluster resource ID |
| `managedClusterClientId` | string | AKS managed identity client ID |
| `managedClusterObjectId` | string | AKS managed identity object ID |
| `containerRegistryName` | string | Container Registry name |
| `containerRegistryLoginServer` | string | Container Registry login server |
| `resourceGroupName` | string | Resource group name |

## Underlying AVM Module

This module wraps: `br/public:avm/ptn/azd/aks:0.2.0`

See the [AVM documentation](https://azure.github.io/Azure-Verified-Modules/) for additional details.

## Version History

| Version | Date | Description |
|---------|------|-------------|
| v1.0.0 | 2024 | Initial release wrapping avm/ptn/azd/aks:0.2.0 |
