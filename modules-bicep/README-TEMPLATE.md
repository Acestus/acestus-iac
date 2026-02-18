# Bicep Modules (Template Notice)

⚠️ **TEMPLATE REPOSITORY NOTICE** ⚠️

This folder contains reusable Bicep modules from the original organization. These are **NOT** required for the core time-logger template functionality.

## What's Here

This directory contains custom Bicep modules that wrap Azure Verified Modules:

- AKS cluster modules
- Storage account modules
- Networking modules
- Security modules
- Organization-specific patterns

## Important Notes

1. **Not Required**: The core time-logger template does not reference these modules
2. **Contains Company Branding**: Module descriptions and comments reference the original organization
3. **Published to Private ACR**: These modules were designed to be published to an Azure Container Registry

## Options for Using This Template

### Option 1: Delete This Folder (Recommended)

If you only need the core AKS time-logger template:

```powershell
Remove-Item -Recurse -Force modules-bicep/
```

### Option 2: Use Azure Verified Modules Directly

Instead of custom wrappers, use official Microsoft modules:

- [Bicep Registry Modules](https://azure.github.io/Azure-Verified-Modules/)
- Reference them directly in your Bicep:

  ```bicep
  module aks 'br/public:avm/res/container-service/managed-cluster:0.1.0' = {
    name: 'aksDeployment'
    params: {
      // your parameters
    }
  }
  ```

### Option 3: Customize These Modules

If you want to use these as a starting point:

1. Update all module metadata to remove original organization references
2. Update module descriptions and comments
3. Set up your own ACR for module publishing
4. Update the publish scripts with your ACR name

## Module Publishing

If you choose to use these modules, see:

- `/modules-bicep/Publish-BicepModule.ps1` - Publishing script (needs ACR name update)
- `.github/workflows/publish-bicep-modules.yml` - CI/CD for modules (needs sanitization)

## Core Template

The main time-logger template infrastructure is in:

- `/infrastructure/main.bicep` - Uses standard Azure resources directly
- No custom modules required
