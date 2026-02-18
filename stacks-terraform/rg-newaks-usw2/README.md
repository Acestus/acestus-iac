# AKS Stack (Terraform)

Terraform stack for deploying an AKS cluster with Container Registry, Key Vault, and monitoring - the Terraform equivalent of `stacks-bicep/rg-aksana-usw2`.

## Overview

This stack uses the `aks-azd-pattern` wrapper module to deploy:
- Resource Group
- AKS Managed Cluster
- Azure Container Registry (with AcrPull access for AKS)
- Azure Key Vault (with RBAC access)
- Log Analytics integration

## Prerequisites

1. Azure CLI authenticated (`az login`)
2. Terraform 1.5.0+
3. Access to ACR for module sources

## Quick Start

```powershell
# Login to ACR for module access
az acr login --name acrskpmgtcrdevusw2001

# Initialize
cd stacks-terraform/rg-newaks-usw2
terraform init

# Deploy dev environment
terraform plan -var-file=environments/dev/terraform.tfvars
terraform apply -var-file=environments/dev/terraform.tfvars
```

## Directory Structure

```
rg-newaks-usw2/
├── main.tf              # Main configuration using aks-azd-pattern module
├── variables.tf         # Input variables
├── outputs.tf           # Stack outputs
├── providers.tf         # Provider and backend configuration
└── environments/
    ├── dev/
    │   └── terraform.tfvars   # Development configuration
    ├── stg/
    │   └── terraform.tfvars   # Staging configuration
    └── prd/
        └── terraform.tfvars   # Production configuration
```

## Environment Configurations

### Development (`dev`)
- **SKU Tier:** Free
- **System Pool:** CostOptimised (Standard_B4ms)
- **Agent Pool:** None
- **Purpose:** Development and testing

### Staging (`stg`)
- **SKU Tier:** Free
- **System Pool:** Standard (Standard_D4s_v5)
- **Agent Pool:** None
- **Purpose:** Pre-production testing

### Production (`prd`)
- **SKU Tier:** Standard (with SLA)
- **System Pool:** Standard (Standard_D4s_v5)
- **Agent Pool:** HighSpec (Standard_D8s_v5)
- **Purpose:** Production workloads

## Configuration

Edit the environment-specific `terraform.tfvars` files:

```hcl
# environments/dev/terraform.tfvars
project_name    = "aksana"
environment     = "dev"
caf_location    = "usw2"
instance_number = "001"

kubernetes_version = "1.30"
sku_tier           = "Free"
system_pool_size   = "CostOptimised"
agent_pool_size    = ""

# Required: Your Log Analytics workspace
monitoring_workspace_id = "/subscriptions/.../resourceGroups/.../providers/Microsoft.OperationalInsights/workspaces/..."
```

## Deployment Commands

```powershell
# Development
terraform apply -var-file=environments/dev/terraform.tfvars

# Staging
terraform apply -var-file=environments/stg/terraform.tfvars

# Production
terraform apply -var-file=environments/prd/terraform.tfvars

# Destroy
terraform destroy -var-file=environments/dev/terraform.tfvars
```

## Outputs

After deployment, these outputs are available:

| Output | Description |
|--------|-------------|
| `resource_group_name` | Name of the created resource group |
| `aks_cluster_name` | Name of the AKS cluster |
| `aks_cluster_fqdn` | FQDN for kubectl access |
| `container_registry_login_server` | ACR login server for docker push |
| `key_vault_uri` | Key Vault URI for secrets |

## Post-Deployment

### Get AKS Credentials

```powershell
az aks get-credentials --resource-group rg-newaks-dev-usw2-001 --name aks-newaks-dev-usw2-001
kubectl get nodes
```

### Push to ACR

```powershell
az acr login --name acrnewaksdevusw2001
docker tag myapp:latest acrnewaksdevusw2001.azurecr.io/myapp:latest
docker push acrnewaksdevusw2001.azurecr.io/myapp:latest
```

## Related

- **Module source:** `modules-terraform/aks-azd-pattern`
- **Documentation:** `docs/README-TERRAFORM.md`
