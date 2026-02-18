# Terraform Infrastructure Stacks (Template Notice)

⚠️ **TEMPLATE REPOSITORY NOTICE** ⚠️

This folder contains example Terraform deployment stacks from the original organization. These are **NOT** required for the core time-logger template functionality.

## What's Here

This directory contains various infrastructure-as-code examples using Terraform:

- Example resource group deployments
- Sample AKS configurations
- Organization-specific deployment patterns

## Important Notes

1. **Not Required**: The core time-logger template (in `/infrastructure` at the root uses Bicep) does not depend on these files
2. **Contains Company-Specific Data**: These files contain hardcoded:
   - Subscription IDs
   - Resource group names
   - Azure Container Registry references
   - Organization naming conventions

## Options for Using This Template

### Option 1: Delete This Folder (Recommended)

If you only need the core AKS time-logger template:

```powershell
Remove-Item -Recurse -Force stacks-terraform/
```

### Option 2: Keep as Examples

If you want to use these as reference examples, you'll need to sanitize:

- Replace all subscription IDs with your own
- Update ACR references to your registry
- Update resource naming conventions
- Remove company-specific configurations

### Option 3: Use Azure Verified Modules Instead

Microsoft provides official Terraform modules that are better maintained:

- [Azure Verified Modules for Terraform](https://azure.github.io/Azure-Verified-Modules/)
- [Terraform Azure Modules](https://registry.terraform.io/namespaces/Azure)

## Core Template

The main time-logger template infrastructure is in:

- `/infrastructure/main.bicep` - Core AKS infrastructure (Bicep)
- `/infrastructure/main.{env}.bicepparam` - Environment parameters
- `/k8s/` - Kubernetes manifests
- `.github/workflows/` - CI/CD pipelines

These files have been sanitized and are ready to use.
