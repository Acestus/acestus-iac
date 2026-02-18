# Terraform Modules (Template Notice)

⚠️ **TEMPLATE REPOSITORY NOTICE** ⚠️

This folder contains reusable Terraform modules from the original organization. These are **NOT** required for the core time-logger template functionality.

## What's Here

This directory contains custom Terraform modules that wrap Azure Verified Modules:

- AKS cluster modules
- Virtual network modules
- Database modules
- Security modules
- Organization-specific patterns

## Important Notes

1. **Not Required**: The core time-logger template uses Bicep, not Terraform
2. **Contains Company Branding**: Module descriptions and comments reference the original organization
3. **Published to Private ACR**: These modules were designed to be published to an Azure Container Registry using ORAS

## Options for Using This Template

### Option 1: Delete This Folder (Recommended)

If you only need the core AKS time-logger template:

```powershell
Remove-Item -Recurse -Force modules-terraform/
```

### Option 2: Use Azure Verified Modules Directly

Instead of custom wrappers, use official Microsoft modules:

- [Azure Verified Modules for Terraform](https://azure.github.io/Azure-Verified-Modules/)
- Reference them from the Terraform Registry:

  ```hcl
  module "aks" {
    source  = "Azure/aks/azurerm"
    version = "~> 6.0"
    // your parameters
  }
  ```

### Option 3: Customize These Modules

If you want to use these as a starting point:

1. Update all module headers to remove original organization references
2. Update module descriptions and comments
3. Set up your own ACR for module publishing
4. Update the publish scripts with your ACR name

## Module Publishing

If you choose to use these modules, see:

- `/modules-terraform/Publish-TerraformModule.ps1` - Publishing script (needs ACR name update)
- Module files contain "Acestus" references that need updating

## Core Template

The main time-logger template infrastructure is in:

- `/infrastructure/main.bicep` - Core AKS infrastructure (Bicep, not Terraform)
- No Terraform required for the core template
