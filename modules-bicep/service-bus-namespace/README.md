# Acestus Service Bus Namespace Module

Custom Bicep module for Service Bus namespaces using AVM with Acestus defaults.

## Parameters

### Required

| Parameter | Type | Description |
|-----------|------|-------------|
| `name` | string | Service Bus namespace name |

### Optional

| Parameter | Type | Default | Description |
|-----------|------|---------|-------------|
| `location` | string | `resourceGroup().location` | Azure region |
| `tags` | object | `{}` | Resource tags |
| `skuObject` | object | `{ name: 'Standard', capacity: 1 }` | SKU configuration |
| `minimumTlsVersion` | string | `1.2` | Minimum TLS version |
| `disableLocalAuth` | bool | `true` | Disable SAS auth |
| `zoneRedundant` | bool | `false` | Zone redundancy |
| `publicNetworkAccess` | string | `Enabled` | Public network access |
| `networkRuleSets` | object | `{}` | Network rules |
| `managedIdentities` | object | `{}` | Managed identities configuration |
| `customerManagedKey` | object | `{}` | CMK configuration |

## Example

```bicep
module serviceBus 'br:acracemgtcrprdwus3001.azurecr.io/bicep/modules/service-bus-namespace:v1.0.0' = {
  name: 'serviceBus'
  params: {
    name: 'sb-myapp-dev-wus3-001'
    location: location
    tags: tags
    skuObject: {
      name: 'Standard'
      capacity: 1
    }
  }
}
```

## Outputs

| Output | Type | Description |
|--------|------|-------------|
| `resourceId` | string | Namespace resource ID |
| `namespaceName` | string | Namespace name |
| `serviceBusEndpoint` | string | Namespace endpoint |
| `resourceGroupName` | string | Resource group name |

## Version History

- **v1.0.1**: Remove secret outputs
- **v1.0.0**: Initial release
