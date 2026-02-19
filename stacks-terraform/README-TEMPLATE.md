# Terraform Infrastructure Stacks (Template Notice)

⚠️ **TEMPLATE REPOSITORY NOTICE** ⚠️

This folder contains example Terraform deployment stacks from the original organization. These are **NOT** required for the core time-logger template functionality.

## What's Here

This directory contains various infrastructure-as-code examples using Terraform:


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


### Option 3: Use Azure Verified Modules Instead

Microsoft provides official Terraform modules that are better maintained:


## Core Template

The main time-logger template infrastructure is in:


These files have been sanitized and are ready to use.
# Terraform Stack Template
- [Terraform Azure Modules](https://registry.terraform.io/namespaces/Azure)
