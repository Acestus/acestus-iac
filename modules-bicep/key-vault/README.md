# Acestus Key Vault Module

Custom Bicep module for Key Vault using AVM with Acestus defaults.

## Parameters

### Required

| Parameter | Type | Description |
|-----------|------|-------------|
| `name` | string | Key Vault name |

### Optional

| Parameter | Type | Default | Description |
|-----------|------|---------|-------------|
| `location` | string | `resourceGroup().location` | Azure region |
| `tags` | object | `{}` | Resource tags |
| `sku` | string | `standard` | Key Vault SKU |
| `enableRbacAuthorization` | bool | `true` | Use RBAC for data plane |
| `enableSoftDelete` | bool | `true` | Enable soft delete |
| `softDeleteRetentionInDays` | int | `90` | Soft delete retention |
| `enablePurgeProtection` | bool | `true` | Enable purge protection |
| `publicNetworkAccess` | string | `Enabled` | Public network access |
| `networkAcls` | object | `Allow + AzureServices` | Network ACLs |
| `accessPolicies` | array | `[]` | Access policies (RBAC disabled only) |

## Example

```bicep
module keyVault 'br:acracemgtcrprdwus3001.azurecr.io/bicep/modules/key-vault:v1.0.0' = {
  name: 'keyVault'
  params: {
    name: 'kv-myapp-dev-wus3-001'
    location: location
    tags: tags
    enableRbacAuthorization: true
  }
}
```

## Outputs

| Output | Type | Description |
|--------|------|-------------|
| `resourceId` | string | Key Vault resource ID |
| `keyVaultUri` | string | Key Vault URI |
| `keyVaultName` | string | Key Vault name |
| `keyVault` | object | All AVM outputs |

## Version History

- **v1.0.0**: Initial release
