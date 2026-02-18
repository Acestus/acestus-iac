# Acestus User Managed Identity Module

Custom Bicep module for user-assigned managed identities using AVM with Acestus defaults.

## Parameters

### Required

| Parameter | Type | Description |
|-----------|------|-------------|
| `name` | string | User managed identity name |

### Optional

| Parameter | Type | Default | Description |
|-----------|------|---------|-------------|
| `location` | string | `resourceGroup().location` | Azure region |
| `tags` | object | `{}` | Resource tags |
| `federatedIdentityCredentials` | array | `[]` | Federated identity credentials |

## Example

```bicep
module umi 'br:acracemgtcrprdwus3001.azurecr.io/bicep/modules/user-managed-identity:v1.0.0' = {
  name: 'umi'
  params: {
    name: 'umi-myapp-dev-wus3-001'
    location: location
    tags: tags
  }
}
```

## Outputs

| Output | Type | Description |
|--------|------|-------------|
| `resourceId` | string | Identity resource ID |
| `principalId` | string | Identity principal ID |
| `clientId` | string | Identity client ID |
| `identityName` | string | Identity name |
| `userManagedIdentity` | object | All AVM outputs |

## Version History

- **v1.0.0**: Initial release
