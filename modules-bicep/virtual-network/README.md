# Acestus Virtual Network Module

This is a custom Bicep module for Azure Virtual Networks that implements Acestus security standards and naming conventions.

## Features

- **Security First**: Supports DDoS protection, encryption, and VM protection
- **Acestus Standards**: Follows organizational security and compliance requirements
- **Flexible Configuration**: Supports various deployment scenarios with subnets, peerings, and DNS configurations
- **Built on AVM**: Uses Azure Verified Modules as the underlying implementation

## Parameters

### Required Parameters

| Parameter | Type | Description |
|-----------|------|-------------|
| `name` | string | Virtual Network name |
| `addressPrefixes` | array | Virtual Network address prefixes (CIDR notation) |

### Optional Parameters

| Parameter | Type | Default | Description |
|-----------|------|---------|-------------|
| `location` | string | `resourceGroup().location` | Azure region |
| `tags` | object | `{}` | Resource tags |
| `subnets` | array | `[]` | Subnets to create |
| `dnsServers` | array | `[]` | Custom DNS servers |
| `enableDdosProtection` | bool | `false` | Enable DDoS protection |
| `ddosProtectionPlanResourceId` | string | `''` | DDoS protection plan resource ID |
| `enableVmProtection` | bool | `false` | Enable VM protection |
| `encryptionEnabled` | bool | `false` | Enable VNet encryption |
| `encryptionEnforcement` | string | `AllowUnencrypted` | Encryption enforcement policy |
| `flowTimeoutInMinutes` | int | `4` | Flow timeout in minutes |
| `peerings` | array | `[]` | VNet peerings |
| `diagnosticSettings` | array | `[]` | Diagnostic settings |
| `lock` | object | `{}` | Lock configuration |
| `roleAssignments` | array | `[]` | Role assignments |

## Usage Examples

### Basic Virtual Network
```bicep
module vnet 'br:acracemgtcrprdusw2001.azurecr.io/bicep/modules/virtual-network:v1.0.0' = {
  name: 'myVnet'
  params: {
    name: 'vnet-myapp-dev-usw2-001'
    addressPrefixes: ['10.0.0.0/16']
  }
}
```

### Virtual Network with Subnets
```bicep
module vnet 'br:acracemgtcrprdusw2001.azurecr.io/bicep/modules/virtual-network:v1.0.0' = {
  name: 'myVnetWithSubnets'
  params: {
    name: 'vnet-myapp-prd-usw2-001'
    addressPrefixes: ['10.0.0.0/16']
    subnets: [
      {
        name: 'snet-app'
        addressPrefix: '10.0.1.0/24'
        networkSecurityGroupResourceId: nsg.outputs.resourceId
        privateEndpointNetworkPolicies: 'Disabled'
      }
      {
        name: 'snet-data'
        addressPrefix: '10.0.2.0/24'
        networkSecurityGroupResourceId: nsg.outputs.resourceId
        serviceEndpoints: [
          { service: 'Microsoft.Storage' }
          { service: 'Microsoft.KeyVault' }
        ]
      }
      {
        name: 'AzureBastionSubnet'
        addressPrefix: '10.0.255.0/26'
      }
    ]
  }
}
```

### Virtual Network with DDoS Protection
```bicep
module vnet 'br:acracemgtcrprdusw2001.azurecr.io/bicep/modules/virtual-network:v1.0.0' = {
  name: 'mySecureVnet'
  params: {
    name: 'vnet-secure-prd-usw2-001'
    addressPrefixes: ['10.1.0.0/16']
    enableDdosProtection: true
    ddosProtectionPlanResourceId: ddosPlan.outputs.resourceId
    encryptionEnabled: true
    encryptionEnforcement: 'DropUnencrypted'
  }
}
```

### Virtual Network with Peering
```bicep
module vnet 'br:acracemgtcrprdusw2001.azurecr.io/bicep/modules/virtual-network:v1.0.0' = {
  name: 'myPeeredVnet'
  params: {
    name: 'vnet-spoke-prd-usw2-001'
    addressPrefixes: ['10.2.0.0/16']
    peerings: [
      {
        remoteVirtualNetworkResourceId: hubVnet.outputs.resourceId
        allowForwardedTraffic: true
        allowVirtualNetworkAccess: true
        useRemoteGateways: true
      }
    ]
  }
}
```

## Outputs

| Output | Type | Description |
|--------|------|-------------|
| `resourceId` | string | The resource ID of the Virtual Network |
| `name` | string | The name of the Virtual Network |
| `resourceGroupName` | string | The resource group the Virtual Network was deployed into |
| `location` | string | The location of the Virtual Network |
| `subnetResourceIds` | array | The resource IDs of the subnets |
| `subnetNames` | array | The names of the subnets |
| `virtualNetwork` | object | All outputs from the AVM module |

## Security Considerations

- Enable DDoS protection for production workloads exposed to the internet
- Use Network Security Groups on all subnets
- Enable VNet encryption for sensitive workloads
- Use private endpoints for Azure PaaS services
- Implement proper subnet segmentation
