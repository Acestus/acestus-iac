# Acestus Storage Account Module

This is a custom Bicep module for Azure Storage Accounts that implements Acestus security standards and naming conventions.

## Features

- **Security First**: Defaults to secure configurations (shared key disabled, HTTPS only, network restrictions)
- **Acestus Standards**: Follows organizational security and compliance requirements
- **Flexible Configuration**: Supports various deployment scenarios while maintaining security
- **Built on AVM**: Uses Azure Verified Modules as the underlying implementation

## Parameters

### Required Parameters

| Parameter | Type | Description |
|-----------|------|-------------|
| `storageAccountName` | string | Globally unique storage account name (3-24 chars, lowercase/numbers) |

### Optional Parameters

| Parameter | Type | Default | Description |
|-----------|------|---------|-------------|
| `location` | string | `resourceGroup().location` | Azure region |
| `skuName` | string | `Standard_ZRS` | Storage account SKU |
| `kind` | string | `StorageV2` | Storage account kind |
| `tags` | object | `{}` | Resource tags |
| `allowedIpRules` | array | `[]` | Allowed IP addresses (CIDR format) |
| `virtualNetworkRules` | array | `[]` | Virtual network rules |
| `defaultNetworkAction` | string | `Deny` | Default network access action |
| `enableBlobSoftDelete` | bool | `true` | Enable blob soft delete |
| `blobSoftDeleteRetentionDays` | int | `30` | Blob soft delete retention period |
| `enableBlobVersioning` | bool | `true` | Enable blob versioning |
| `enableContainerSoftDelete` | bool | `true` | Enable container soft delete |
| `containerSoftDeleteRetentionDays` | int | `30` | Container soft delete retention |
| `allowSharedKeyAccess` | bool | `false` | Enable shared key access |
| `allowBlobPublicAccess` | bool | `false` | Enable blob public access |
| `minimumTlsVersion` | string | `TLS1_2` | Minimum TLS version |

## Usage Examples

### Basic Storage Account
```bicep
module storage 'br:acracemgtcrprdusw2001.azurecr.io/bicep/modules/storage-account:v1.0.0' = {
  name: 'myStorage'
  params: {
    storageAccountName: 'stmyappdevusw2001'
    allowedIpRules: ['192.168.1.0/24']
  }
}
```

### Storage Account with Customer Managed Keys
```bicep
module storage 'br:acracemgtcrprdusw2001.azurecr.io/bicep/modules/storage-account:v1.0.0' = {
  name: 'myEncryptedStorage'
  params: {
    storageAccountName: 'stmyappprdusw2001'
    allowedIpRules: ['192.168.1.0/24']
    customerManagedKey: {
      keyName: 'storage-key'
      keyVaultResourceId: keyVault.outputs.resourceId
      userAssignedIdentityResourceId: managedIdentity.outputs.resourceId
    }
    managedIdentities: {
      userAssignedResourceIds: [managedIdentity.outputs.resourceId]
    }
  }
}
```

### Storage Account with Blob Containers
```bicep
module storage 'br:acracemgtcrprdusw2001.azurecr.io/bicep/modules/storage-account:v1.0.0' = {
  name: 'myStorageWithContainers'
  params: {
    storageAccountName: 'stmyfuncprdusw2001'
    allowedIpRules: ['192.168.1.0/24']
    blobContainers: [
      {
        name: 'azure-webjobs-hosts'
        publicAccess: 'None'
      }
      {
        name: 'azure-webjobs-secrets'
        publicAccess: 'None'
      }
      {
        name: 'data'
        publicAccess: 'None'
      }
    ]
  }
}
```

## Outputs

| Output | Type | Description |
|--------|------|-------------|
| `resourceId` | string | Storage account resource ID |
| `name` | string | Storage account name |
| `primaryEndpoints` | object | Primary service endpoints |
| `primaryKey` | string | Primary access key |
| `secondaryKey` | string | Secondary access key |
| `connectionString` | string | Connection string |
| `storageAccount` | object | All AVM module outputs |

## Security Features

- **Network Isolation**: Defaults to deny public access with IP allowlisting
- **No Shared Keys**: OAuth authentication preferred by default
- **HTTPS Only**: Secure transport enforced
- **Soft Delete**: Protection against accidental deletion
- **Versioning**: Built-in data protection
- **Minimum TLS 1.2**: Modern security standards

## Version History

- **v1.0.0**: Initial release with Acestus security standards