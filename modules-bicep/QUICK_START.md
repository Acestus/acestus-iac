# Bicep Module Management Quick Start Guide

This guide helps you get started with managing custom Bicep modules in your Azure Container Registry (ACR).

## 🚀 Quick Start

### 1. Test the Storage Account Module

First, test the module locally:

```powershell
cd bicep\modules
.\Test-Module.ps1 -ModuleName "storage-account"
```

### 2. Publish the Module to ACR

Publish your first module:

```powershell
.\Publish-BicepModule.ps1 -ModuleName "storage-account" -Version "v1.0.0"
```

### 3. Use the Module in a Template

Reference your custom module:

```bicep
module storage 'br:acracemgtcrprdusw2001.azurecr.io/bicep/modules/storage-account:v1.0.0' = {
  name: 'myStorage'
  params: {
    storageAccountName: 'stmyappdevusw2001'
    allowedIpRules: ['192.168.1.0/24']
    tags: {
      Environment: 'dev'
      Project: 'MyApp'
    }
  }
}
```

### 4. Test the Example

Deploy the example to see it in action:

```powershell
cd modules-bicep\examples
.\deploy-example.ps1 -WhatIf  # Test first
.\deploy-example.ps1          # Deploy for real
```

## 📚 Available Scripts

| Script | Purpose | Example |
|--------|---------|---------|
| `Test-Module.ps1` | Validate module syntax and quality | `.\Test-Module.ps1 -ModuleName "storage-account"` |
| `Publish-BicepModule.ps1` | Publish single module to ACR | `.\Publish-BicepModule.ps1 -ModuleName "storage-account" -Version "v1.0.0"` |
| `Publish-AllModules.ps1` | Publish all modules at once | `.\Publish-AllModules.ps1 -Version "v1.0.0"` |
| `List-ModuleVersions.ps1` | Show published versions | `.\List-ModuleVersions.ps1 -ModuleName "storage-account"` |

## 🔄 Automated Publishing

Modules are automatically published when you:
1. Push changes to the `main` branch under `modules-bicep/`
2. Manually trigger the "Publish Bicep Modules" workflow

## 🏗️ Creating New Modules

### 1. Module Structure
```
modules-bicep/
└── your-module-name/
    ├── your-module-name.bicep    # Main module file
    ├── README.md                 # Documentation
    └── examples/                 # Usage examples (optional)
        ├── example.bicep
        └── example.bicepparam
```

### 2. Module Template
Your module should include:

```bicep
metadata name = 'Your Module Name'
metadata description = 'Module description'
metadata version = '1.0.0'

@description('Parameter description')
param parameterName string

// Use AVM modules as building blocks
module resource 'br/public:avm/res/resource-type:version' = {
  name: 'resourceDeployment'
  params: {
    // Configure AVM module
  }
}

@description('Output description')
output outputName string = resource.outputs.property
```

## 📋 Migration Checklist

To migrate existing templates to use custom modules:

- [ ] Identify repeated resource patterns
- [ ] Create custom module with security defaults
- [ ] Test module syntax and deployment
- [ ] Publish module to ACR
- [ ] Update templates to use custom module
- [ ] Verify deployments work correctly
- [ ] Update documentation

## 🔧 Benefits of Custom Modules

### Before (Direct AVM)
```bicep
module storageAccount 'br/public:avm/res/storage/storage-account:0.18.1' = {
  name: storageName
  params: {
    name: storageName
    location: location
    skuName: storageSKU
    defaultToOAuthAuthentication: false
    allowSharedKeyAccess: false
    minimumTlsVersion: 'TLS1_2'
    supportsHttpsTrafficOnly: true
    allowBlobPublicAccess: false
    networkAcls: {
      defaultAction: 'Deny'
      bypass: 'AzureServices'
      ipRules: [
        {
          action: 'Allow'
          value: allowedIP
        }
      ]
    }
    blobServices: {
      deleteRetentionPolicy: {
        enabled: true
        allowPermanentDelete: false
        days: 30
      }
      automaticSnapshotPolicyEnabled: false
      containerDeleteRetentionPolicy: {
        enabled: true
        allowPermanentDelete: false
        days: 30
      }
      lastAccessTimeTrackingPolicy: {
        enable: true
        name: 'AccessTimeTracking'
        trackingGranularityInDays: 1
      }
      isVersioningEnabled: true
    }
    tags: tags
  }
}
```

### After (Custom Module)
```bicep
module storageAccount 'br:acracemgtcrprdusw2001.azurecr.io/bicep/modules/storage-account:v1.0.0' = {
  name: storageName
  params: {
    storageAccountName: storageName
    location: location
    skuName: storageSKU
    allowedIpRules: [allowedIP]
    tags: tags
    // Security defaults applied automatically!
  }
}
```

## 🎯 Next Steps

1. **Test the storage account module** with your existing parameters
2. **Publish your first module** to ACR
3. **Migrate one existing resource group** to use the custom module
4. **Create modules for other common patterns** (Key Vault, Function Apps, etc.)
5. **Set up automated testing** for your modules

## 🔍 Troubleshooting

### Common Issues

**"Cannot access ACR"**
- Ensure you have `AcrPush` and `AcrPull` roles on the container registry
- Run `az acr login --name acracemgtcrprdusw2001`

**"Module not found"**
- Check module name and version: `.\List-ModuleVersions.ps1 -ModuleName "storage-account"`
- Ensure ACR login is valid

**"Bicep compilation errors"**
- Run `.\Test-Module.ps1 -ModuleName "your-module"` first
- Check syntax with `az bicep build --file path/to/module.bicep`

## 📖 Documentation

- [Storage Account Module](storage-account/README.md) - Detailed parameter reference
- [Examples](examples/README.md) - Usage examples and migration guides
- [Azure Container Registry Documentation](https://docs.microsoft.com/en-us/azure/container-registry/)