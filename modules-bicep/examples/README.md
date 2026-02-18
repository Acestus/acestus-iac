# Example: Using Custom Storage Account Module from ACR
# This directory demonstrates how to consume custom Bicep modules published to your ACR

## Directory Contents

- **example-using-custom-storage.bicep**: Example template using the custom storage account module
- **example-using-custom-storage.bicepparam**: Parameters file for the example
- **deploy-example.ps1**: Deployment script for testing the example

## How to Use Custom Modules

### 1. Reference Format
```bicep
module storage 'br:acracemgtcrprdusw2001.azurecr.io/bicep/modules/storage-account:v1.0.0' = {
  name: 'customStorage'
  params: {
    // module parameters
  }
}
```

### 2. Version Pinning
Always pin to specific versions in production:
- ✅ Good: `v1.0.0` (specific version)
- ❌ Bad: `latest` (unpredictable)

### 3. Security Benefits
Custom modules provide:
- Consistent security defaults across all deployments
- Organizational compliance built-in
- Reduced template complexity
- Centralized maintenance

## Migration from AVM

### Before (using AVM directly):
```bicep
module storageAccount 'br/public:avm/res/storage/storage-account:0.18.1' = {
  name: storageName
  params: {
    name: storageName
    location: location
    skuName: storageSKU
    defaultToOAuthAuthentication: false
    networkAcls: {
      defaultAction: 'Deny'
      ipRules: [
        {
          action: 'Allow'
          value: allowedIP
        }
      ]
    }
    // ... many more security parameters
  }
}
```

### After (using custom module):
```bicep
module storageAccount 'br:acracemgtcrprdusw2001.azurecr.io/bicep/modules/storage-account:v1.0.0' = {
  name: storageName
  params: {
    storageAccountName: storageName
    location: location
    skuName: storageSKU
    allowedIpRules: [allowedIP]
    // Security defaults applied automatically
  }
}
```