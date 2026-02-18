# Acestus AKS Managed Cluster Module

This is a custom Bicep module for Azure Kubernetes Service (AKS) that implements Acestus security standards and naming conventions.

## Features

- **Security First**: Azure RBAC, Azure AD integration, Defender for Kubernetes, Azure Policy
- **Acestus Standards**: Follows organizational security and compliance requirements
- **Production Ready**: Auto-upgrades, availability zones, workload identity, secrets store CSI driver
- **Flexible Configuration**: Supports various network configurations and add-ons
- **Built on AVM**: Uses Azure Verified Modules as the underlying implementation

## Parameters

### Required Parameters

| Parameter | Type | Description |
|-----------|------|-------------|
| `name` | string | AKS cluster name |

### Optional Parameters

| Parameter | Type | Default | Description |
|-----------|------|---------|-------------|
| `location` | string | `resourceGroup().location` | Azure region |
| `tags` | object | `{}` | Resource tags |
| `kubernetesVersion` | string | `1.29` | Kubernetes version |
| `dnsPrefix` | string | `name` | DNS prefix |
| `systemAgentPoolProfile` | object | See below | System node pool config |
| `agentPools` | array | `[]` | User node pools |
| `enableAzureRBAC` | bool | `true` | Enable Azure RBAC for K8s |
| `enableAadAuthentication` | bool | `true` | Enable Azure AD integration |
| `aadAdminGroupObjectIds` | array | `[]` | Azure AD admin group IDs |
| `disableLocalAccounts` | bool | `true` | Disable local accounts |
| `networkPlugin` | string | `azure` | Network plugin (azure/kubenet) |
| `networkPluginMode` | string | `overlay` | Network plugin mode |
| `networkPolicy` | string | `azure` | Network policy |
| `enablePrivateCluster` | bool | `false` | Enable private cluster |
| `skuTier` | string | `Standard` | AKS SKU tier |
| `enableAutoUpgrade` | bool | `true` | Enable auto-upgrade |
| `autoUpgradeChannel` | string | `stable` | Auto-upgrade channel |
| `enableDefender` | bool | `true` | Enable Defender for K8s |
| `enableAzureMonitor` | bool | `true` | Enable Azure Monitor |
| `enableSecretStoreCSIDriver` | bool | `true` | Enable secrets store CSI |
| `enableAzurePolicy` | bool | `true` | Enable Azure Policy |
| `enableOidcIssuer` | bool | `true` | Enable OIDC issuer |
| `enableWorkloadIdentity` | bool | `true` | Enable workload identity |

### Default System Pool Configuration

```bicep
systemAgentPoolProfile: {
  name: 'system'
  count: 3
  vmSize: 'Standard_D4s_v5'
  osDiskSizeGB: 128
  osDiskType: 'Managed'
  osType: 'Linux'
  mode: 'System'
  enableAutoScaling: true
  minCount: 2
  maxCount: 5
  availabilityZones: ['1', '2', '3']
  maxPods: 30
  nodeTaints: ['CriticalAddonsOnly=true:NoSchedule']
}
```

## Usage Examples

### Basic AKS Cluster
```bicep
module aks 'br:acracemgtcrprdusw2001.azurecr.io/bicep/modules/aks-cluster:v1.0.0' = {
  name: 'myAksCluster'
  params: {
    name: 'aks-myapp-dev-usw2-001'
    aadAdminGroupObjectIds: ['00000000-0000-0000-0000-000000000000']
    logAnalyticsWorkspaceResourceId: logAnalytics.outputs.resourceId
  }
}
```

### AKS with VNet Integration
```bicep
module aks 'br:acracemgtcrprdusw2001.azurecr.io/bicep/modules/aks-cluster:v1.0.0' = {
  name: 'myAksWithVnet'
  params: {
    name: 'aks-myapp-prd-usw2-001'
    subnetResourceId: aksSubnet.outputs.resourceId
    aadAdminGroupObjectIds: ['00000000-0000-0000-0000-000000000000']
    logAnalyticsWorkspaceResourceId: logAnalytics.outputs.resourceId
    agentPools: [
      {
        name: 'workload'
        count: 3
        vmSize: 'Standard_D8s_v5'
        osDiskSizeGB: 128
        mode: 'User'
        enableAutoScaling: true
        minCount: 2
        maxCount: 10
        availabilityZones: ['1', '2', '3']
        maxPods: 50
        nodeLabels: {
          workload: 'general'
        }
      }
    ]
  }
}
```

### Private AKS Cluster
```bicep
module aks 'br:acracemgtcrprdusw2001.azurecr.io/bicep/modules/aks-cluster:v1.0.0' = {
  name: 'myPrivateAks'
  params: {
    name: 'aks-secure-prd-usw2-001'
    enablePrivateCluster: true
    privateDNSZone: privateDnsZone.outputs.resourceId
    subnetResourceId: aksSubnet.outputs.resourceId
    outboundType: 'userDefinedRouting'
    aadAdminGroupObjectIds: ['00000000-0000-0000-0000-000000000000']
    logAnalyticsWorkspaceResourceId: logAnalytics.outputs.resourceId
  }
}
```

### AKS with Cilium (Advanced Networking)
```bicep
module aks 'br:acracemgtcrprdusw2001.azurecr.io/bicep/modules/aks-cluster:v1.0.0' = {
  name: 'myAksWithCilium'
  params: {
    name: 'aks-cilium-prd-usw2-001'
    networkPlugin: 'azure'
    networkPluginMode: 'overlay'
    networkPolicy: 'cilium'
    networkDataplane: 'cilium'
    subnetResourceId: aksSubnet.outputs.resourceId
    aadAdminGroupObjectIds: ['00000000-0000-0000-0000-000000000000']
    logAnalyticsWorkspaceResourceId: logAnalytics.outputs.resourceId
  }
}
```

### AKS with AGIC (Application Gateway Ingress Controller)
```bicep
module aks 'br:acracemgtcrprdusw2001.azurecr.io/bicep/modules/aks-cluster:v1.0.0' = {
  name: 'myAksWithAgic'
  params: {
    name: 'aks-web-prd-usw2-001'
    subnetResourceId: aksSubnet.outputs.resourceId
    ingressApplicationGatewayEnabled: true
    appGatewayResourceId: appGateway.outputs.resourceId
    aadAdminGroupObjectIds: ['00000000-0000-0000-0000-000000000000']
    logAnalyticsWorkspaceResourceId: logAnalytics.outputs.resourceId
  }
}
```

## Outputs

| Output | Type | Description |
|--------|------|-------------|
| `resourceId` | string | The resource ID of the AKS cluster |
| `name` | string | The name of the AKS cluster |
| `resourceGroupName` | string | The resource group |
| `location` | string | The location |
| `controlPlaneFQDN` | string | The control plane FQDN |
| `kubeletIdentityObjectId` | string | Kubelet identity object ID |
| `kubeletIdentityClientId` | string | Kubelet identity client ID |
| `oidcIssuerUrl` | string | OIDC issuer URL for workload identity |
| `systemAssignedMIPrincipalId` | string | Principal ID of system identity |
| `aksCluster` | object | All outputs from AVM module |

## Security Considerations

- Always use Azure RBAC for Kubernetes authorization
- Disable local accounts for production clusters
- Enable Azure Defender for Kubernetes
- Use private clusters for sensitive workloads
- Enable Azure Policy for compliance enforcement
- Use workload identity instead of pod identity
- Enable secrets store CSI driver for secret management
- Use managed NAT gateway or user-defined routing for egress control
- Enable network policies for pod-to-pod traffic control
- Use availability zones for high availability
- Enable auto-upgrades with appropriate maintenance windows

## Node Pool Best Practices

- Use dedicated system node pool with taints
- Separate workloads by node pool for resource isolation
- Enable autoscaling for dynamic workloads
- Use Premium SSD for production workloads
- Configure appropriate max pods per node
