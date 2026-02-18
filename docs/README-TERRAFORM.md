# Terraform Module Publishing and Usage Guide

This guide explains how to publish Terraform modules to Azure Container Registry (ACR) and reference them in your infrastructure stacks.

## Overview

This IaC repository uses Azure Container Registry (ACR) to store and version Terraform modules. This provides:

- **Version control** for modules independent of the Git repository
- **Immutable artifacts** that can be referenced by stacks
- **Private module registry** secured by Azure RBAC
- **Compatibility** with Terraform's native module source syntax

## Directory Structure

```
modules-terraform/
├── Publish-TerraformModule.ps1     # Publishing script
├── Publish-AllModules.ps1          # Publish all modules
├── aks-azd-pattern/                # Example AVM wrapper module
│   ├── main.tf                     # Module resources
│   ├── variables.tf                # Input variables
│   ├── outputs.tf                  # Output values
│   └── versions.tf                 # Provider requirements
└── ...

stacks-terraform/
└── rg-aksana-swc/                 # Example stack
    ├── main.tf                     # Stack configuration
    ├── variables.tf                # Stack variables
    ├── outputs.tf                  # Stack outputs
    ├── providers.tf                # Provider config
    └── environments/
        ├── dev/
        │   └── terraform.tfvars    # Dev variables
        ├── stg/
        │   └── terraform.tfvars    # Staging variables
        └── prd/
            └── terraform.tfvars    # Production variables
```

## Publishing Modules

### Prerequisites

1. **Azure CLI** installed and authenticated (`az login`)
2. **Terraform** installed (version 1.5.0+)
3. **Access to ACR** (your ACR instance for dev/prod)

### Publishing a Single Module

```powershell
cd modules-terraform

# Preview what will be published
.\Publish-TerraformModule.ps1 -ModuleName "aks-azd-pattern" -Version "v1.0.0" -WhatIf

# Publish the module
.\Publish-TerraformModule.ps1 -ModuleName "aks-azd-pattern" -Version "v1.0.0"

# Force overwrite existing version
.\Publish-TerraformModule.ps1 -ModuleName "aks-azd-pattern" -Version "v1.0.0" -Force
```

### Publishing to Production ACR

```powershell
.\Publish-TerraformModule.ps1 -ModuleName "aks-azd-pattern" -Version "v1.0.0" -RegistryName "<your-acr-name>"
```

### Version Format

Versions should follow semantic versioning with a `v` prefix:

- `v1.0.0` - Initial release
- `v1.1.0` - New features, backward compatible
- `v2.0.0` - Breaking changes

## Referencing Modules

### From ACR (Recommended for Production)

```hcl
module "aks_stack" {
  source  = "oci://<your-acr-name>.azurecr.io/terraform/modules/aks-azd-pattern"
  version = "1.0.0"

  # Module parameters
  aks_name                = "aks-myapp-dev-swc-001"
  container_registry_name = "acrmyappdevswc001"
  key_vault_name          = "kv-myapp-dev-swc"
  resource_group_name     = azurerm_resource_group.main.name
  location                = azurerm_resource_group.main.location

  # ...
}
```

### From Local Path (Development)

During module development, use a relative path:

```hcl
module "aks_stack" {
  source = "../../modules-terraform/aks-azd-pattern"

  # Module parameters...
}
```

## Creating AVM Wrapper Modules

Wrapper modules encapsulate Azure Verified Modules (AVM) with organization-specific defaults:

### Module Structure

```hcl
# main.tf
module "aks" {
  source  = "Azure/avm-res-containerservice-managedcluster/azurerm"
  version = "~> 0.4"

  # Standard configuration with org defaults
  name                = var.aks_name
  resource_group_name = var.resource_group_name
  location            = var.location

  # ... with sensible defaults applied
}

# variables.tf
variable "aks_name" {
  type        = string
  description = "The name of the AKS cluster"
}

# outputs.tf
output "aks_name" {
  description = "The name of the AKS cluster"
  value       = module.aks.name
}

# versions.tf
terraform {
  required_version = ">= 1.5.0"
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = ">= 3.71.0"
    }
  }
}
```

## Stack Deployment

### Initialize and Deploy

```powershell
cd stacks-terraform/rg-aksana-swc

# Initialize with ACR authentication
az acr login --name <your-acr-name>
terraform init

# Deploy to dev environment
terraform plan -var-file=environments/dev/terraform.tfvars
terraform apply -var-file=environments/dev/terraform.tfvars

# Deploy to production
terraform plan -var-file=environments/prd/terraform.tfvars
terraform apply -var-file=environments/prd/terraform.tfvars
```

### Backend Configuration

For remote state, configure the backend in `providers.tf`:

```hcl
terraform {
  backend "azurerm" {
    resource_group_name  = "rg-terraform-state"
    storage_account_name = "stterraformstate"
    container_name       = "tfstate"
    key                  = "rg-aksana-swc.tfstate"
  }
}
```

## Available Modules

| Module | Version | Description |
|--------|---------|-------------|
| `aks-azd-pattern` | v1.0.0 | AKS cluster with ACR, Key Vault, and monitoring |
| `aks-cluster` | v1.0.0 | AKS cluster (standalone) |
| `container-registry` | v1.0.0 | Azure Container Registry |
| `key-vault` | v1.0.0 | Azure Key Vault |
| `storage-account` | v1.0.0 | Azure Storage Account |

## Pool Size Presets

The `aks-azd-pattern` module supports VM size presets:

| Preset | VM Size | Use Case |
|--------|---------|----------|
| `CostOptimised` | Standard_B4ms | Dev/Test workloads |
| `Standard` | Standard_D4s_v5 | General purpose |
| `HighSpec` | Standard_D8s_v5 | Production workloads |

## Troubleshooting

### ACR Authentication

```powershell
# Login to ACR
az acr login --name <your-acr-name>

# Verify access
az acr repository list --name <your-acr-name>
```

### Module Not Found

1. Ensure you're logged into ACR: `az acr login --name <your-acr-name>`
2. Check the module exists: `az acr repository show-tags --name <your-acr-name> --repository terraform/modules/aks-azd-pattern`
3. Verify the version format (without `v` prefix in source)

### Init Fails with Provider Errors

Run `terraform init -upgrade` to update provider versions.

## Related Documentation

- [Azure Verified Modules](https://azure.github.io/Azure-Verified-Modules/)
- [Terraform ACR Module Source](https://developer.hashicorp.com/terraform/language/modules/sources#azure-container-registry)
- [Bicep Module Publishing](../modules-bicep/README.md)
