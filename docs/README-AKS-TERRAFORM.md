# AKS Deployment with Terraform

This guide covers deploying AKS clusters using Terraform with the AKS AZD Pattern module.

## Quick Start

```powershell
# 1. Login to Azure and ACR
az login
az acr login --name <your-acr-name>

# 2. Initialize and deploy
cd stacks-terraform/rg-newaks-swc
terraform init
terraform apply -var-file=environments/dev/terraform.tfvars
```

## Architecture

The `aks-azd-pattern` module deploys a complete AKS environment:

```
┌─────────────────────────────────────────────────────────────┐
│                     Resource Group                          │
│  ┌─────────────┐  ┌─────────────┐  ┌─────────────────────┐ │
│  │     AKS     │  │     ACR     │  │     Key Vault       │ │
│  │   Cluster   │──│  (AcrPull)  │  │  (RBAC enabled)     │ │
│  │             │  │             │  │                     │ │
│  │ ┌─────────┐ │  └─────────────┘  └─────────────────────┘ │
│  │ │ System  │ │                                           │
│  │ │  Pool   │ │        ┌─────────────────────────┐        │
│  │ └─────────┘ │        │   Log Analytics         │        │
│  │ ┌─────────┐ │────────│   (Diagnostics)         │        │
│  │ │ Agent   │ │        └─────────────────────────┘        │
│  │ │  Pool   │ │                                           │
│  │ └─────────┘ │                                           │
│  └─────────────┘                                           │
└─────────────────────────────────────────────────────────────┘
```

## Directory Structure

```
modules-terraform/
└── aks-azd-pattern/          # AVM wrapper module
    ├── main.tf               # AKS, ACR, Key Vault resources
    ├── variables.tf          # Input variables
    ├── outputs.tf            # Outputs
    └── versions.tf           # Provider requirements

stacks-terraform/
└── rg-newaks-swc/           # AKS stack
    ├── main.tf               # Stack configuration
    ├── variables.tf          # Stack variables
    ├── outputs.tf            # Stack outputs
    ├── providers.tf          # Provider config
    └── environments/
        ├── dev/terraform.tfvars
        ├── stg/terraform.tfvars
        └── prd/terraform.tfvars
```

## Module Usage

### From ACR (Production)

```hcl
module "aks_stack" {
  source  = "oci://<your-acr-name>.azurecr.io/terraform/modules/aks-azd-pattern"
  version = "1.0.0"

  aks_name                = "aks-myapp-dev-swc-001"
  container_registry_name = "acrmyappdevswc001"
  key_vault_name          = "kv-myapp-dev-swc"
  resource_group_name     = azurerm_resource_group.main.name
  location                = azurerm_resource_group.main.location

  monitoring_workspace_id = var.monitoring_workspace_id

  kubernetes_version = "1.30"
  sku_tier           = "Free"
  system_pool_size   = "Standard"
  agent_pool_size    = ""

  tags = var.tags
}
```

### From Local Path (Development)

```hcl
module "aks_stack" {
  source = "../../modules-terraform/aks-azd-pattern"
  # ... same parameters
}
```

## Pool Size Presets

| Preset | VM SKU | vCPU | RAM | Use Case |
|--------|--------|------|-----|----------|
| `CostOptimised` | Standard_B4ms | 4 | 16 GB | Dev/Test |
| `Standard` | Standard_D4s_v5 | 4 | 16 GB | General |
| `HighSpec` | Standard_D8s_v5 | 8 | 32 GB | Production |

## Environment Configurations

### Development

```hcl
sku_tier         = "Free"
system_pool_size = "CostOptimised"
agent_pool_size  = ""  # No agent pool
```

### Staging

```hcl
sku_tier         = "Free"
system_pool_size = "Standard"
agent_pool_size  = ""
```

### Production

```hcl
sku_tier         = "Standard"  # SLA
system_pool_size = "Standard"
agent_pool_size  = "HighSpec"
```

## Deployment

### Initialize

```powershell
cd stacks-terraform/rg-newaks-swc
az acr login --name <your-acr-name>
terraform init
```

### Plan & Apply

```powershell
# Development
terraform plan -var-file=environments/dev/terraform.tfvars
terraform apply -var-file=environments/dev/terraform.tfvars

# Production
terraform plan -var-file=environments/prd/terraform.tfvars
terraform apply -var-file=environments/prd/terraform.tfvars
```

### Destroy

```powershell
terraform destroy -var-file=environments/dev/terraform.tfvars
```

## Post-Deployment

### Get Cluster Credentials

```powershell
# Get credentials
az aks get-credentials --resource-group rg-newaks-dev-swc-001 --name aks-newaks-dev-swc-001

# Verify
kubectl get nodes
kubectl cluster-info
```

### Push Images to ACR

```powershell
# Login to ACR
az acr login --name acrnewaksdevswc001

# Tag and push
docker tag myapp:latest acrnewaksdevswc001.azurecr.io/myapp:v1.0.0
docker push acrnewaksdevswc001.azurecr.io/myapp:v1.0.0
```

### Deploy to AKS

```yaml
# deployment.yaml
apiVersion: apps/v1
kind: Deployment
metadata:
  name: myapp
spec:
  replicas: 3
  selector:
    matchLabels:
      app: myapp
  template:
    metadata:
      labels:
        app: myapp
    spec:
      containers:
      - name: myapp
        image: acrnewaksdevswc001.azurecr.io/myapp:v1.0.0
        ports:
        - containerPort: 8080
```

```powershell
kubectl apply -f deployment.yaml
```

## Key Parameters

| Parameter | Description | Default |
|-----------|-------------|---------|
| `aks_name` | AKS cluster name | Required |
| `container_registry_name` | ACR name (globally unique) | Required |
| `key_vault_name` | Key Vault name | Required |
| `kubernetes_version` | K8s version | `"1.30"` |
| `sku_tier` | Free, Standard, Premium | `"Free"` |
| `system_pool_size` | CostOptimised, Standard, HighSpec | `"Standard"` |
| `agent_pool_size` | CostOptimised, Standard, HighSpec, or empty | `""` |
| `enable_azure_rbac` | Azure RBAC for K8s | `true` |
| `enable_workload_identity` | Workload identity | `true` |
| `enable_private_cluster` | Private cluster | `false` |

## Outputs

| Output | Description |
|--------|-------------|
| `aks_cluster_name` | AKS cluster name |
| `aks_cluster_fqdn` | FQDN for kubectl |
| `aks_oidc_issuer_url` | OIDC issuer for workload identity |
| `container_registry_login_server` | ACR login server |
| `key_vault_uri` | Key Vault URI |

## Publishing the Module

```powershell
cd modules-terraform

# Publish to dev ACR
.\Publish-TerraformModule.ps1 -ModuleName "aks-azd-pattern" -Version "v1.0.0"

# Publish to prod ACR
.\Publish-TerraformModule.ps1 -ModuleName "aks-azd-pattern" -Version "v1.0.0" -RegistryName "<your-acr-name>"
```

## Troubleshooting

### ACR Authentication Failed

```powershell
az acr login --name <your-acr-name>
```

### Module Not Found

```powershell
# Verify module exists
az acr repository show-tags --name <your-acr-name> --repository terraform/modules/aks-azd-pattern
```

### Provider Version Issues

```powershell
terraform init -upgrade
```

### Kubernetes Connection Issues

```powershell
# Re-fetch credentials
az aks get-credentials --resource-group <rg-name> --name <aks-name> --overwrite-existing
```

## Related Files

- Module: `modules-terraform/aks-azd-pattern/`
- Stack: `stacks-terraform/rg-newaks-swc/`
- Full Terraform docs: `docs/README-TERRAFORM.md`
