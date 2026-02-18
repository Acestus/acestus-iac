# AKS Deployment with ArgoCD

This reusable workflow deploys .NET applications to Azure Kubernetes Service (AKS) using ArgoCD for GitOps-based deployments.

## Overview

The workflow:
1. Deploys/updates Azure infrastructure using Bicep (if changed)
2. Builds .NET applications as Docker containers
3. Pushes images to Azure Container Registry (ACR)
4. Deploys to AKS via ArgoCD

## Prerequisites

### Azure Resources
- AKS cluster (deployed via infrastructure template)
- Azure Container Registry (ACR)
- Service Principal with OIDC configured for GitHub Actions
- Managed Identity for AKS to pull from ACR

### GitHub Configuration
- Repository variables:
  - `AZURE_CLIENT_ID` - Service Principal Client ID
  - `AZURE_TENANT_ID` - Azure AD Tenant ID
  - `AZURE_SUBSCRIPTION_ID` - Azure Subscription ID
  - `ACR_NAME` - Azure Container Registry name (without .azurecr.io)

- Repository secrets:
  - `GITHUB_AUTH_PAT` - Personal Access Token for ArgoCD to access manifests repository

### ArgoCD Setup
- ArgoCD installed and configured
- GitOps repository for Kubernetes manifests
- ArgoCD application configured for your namespace/environment

## Usage

Create a workflow file (e.g., `.github/workflows/deploy-aks.yaml`):

```yaml
name: Deploy to AKS

on:
  push:
    branches: [ 'main' ]

jobs:
  deploy:
    uses: ./.github/workflows/aks-deploy-dotnet.yaml
    with:
      environment: prd
      resource_group_name: rg-myapp-prd-swc
      stack_name: stack-myapp-prd
      acr_name: ${{ vars.ACR_NAME }}
      applications_json: |
        [
          {
            "path": "src/api",
            "name": "myapp-api",
            "image": "myapp/api",
            "dockerfile": "Dockerfile"
          }
        ]
      argocd_cluster_url: https://github.com/yourorg/k8s-manifests/blob/main/clusters/prod/apps
      argocd_namespace: production
      azure_client_id: ${{ vars.AZURE_CLIENT_ID }}
      azure_tenant_id: ${{ vars.AZURE_TENANT_ID }}
      azure_subscription_id: ${{ vars.AZURE_SUBSCRIPTION_ID }}
    secrets:
      GITHUB_AUTH_PAT: ${{ secrets.GITHUB_AUTH_PAT }}
```

## Inputs

### Required Inputs

| Input | Description |
|-------|-------------|
| `resource_group_name` | Azure resource group name |
| `stack_name` | Azure deployment stack name |
| `azure_client_id` | Azure Service Principal Client ID |
| `azure_tenant_id` | Azure AD Tenant ID |
| `azure_subscription_id` | Azure Subscription ID |
| `acr_name` | Azure Container Registry name |
| `argocd_cluster_url` | ArgoCD cluster URL or GitHub manifests repo path |
| `argocd_namespace` | Kubernetes namespace for deployment |

### Optional Inputs

| Input | Default | Description |
|-------|---------|-------------|
| `environment` | `prd` | Deployment environment |
| `template_file` | `infrastructure/main.bicep` | Bicep template path |
| `params_file` | `infrastructure/main.prd.bicepparam` | Bicep parameters file |
| `infra_path_prefix` | `infrastructure/` | Path prefix to watch for infra changes |
| `force_infra` | `false` | Force infrastructure deployment |
| `applications_json` | `[]` | JSON array of applications to deploy |
| `dotnet_version` | `8.0` | .NET SDK version |
| `argocd_toolchain` | `helmfile` | ArgoCD toolchain (helmfile, helm, kustomize) |
| `argocd_synchronously` | `true` | Wait for deployment completion |
| `argocd_debug` | `false` | Enable ArgoCD debug mode |

## Applications JSON Format

The `applications_json` input expects a JSON array of application definitions:

```json
[
  {
    "path": "src/api",           // Path to application source
    "name": "myapp-api",          // Application name
    "image": "myapp/api",         // Image name (without registry)
    "dockerfile": "Dockerfile"    // Dockerfile path (optional, defaults to "Dockerfile")
  }
]
```

## Image Tagging Strategy

Images are tagged with:
- `<acr>.azurecr.io/<image-name>:<git-sha>` - Specific commit
- `<acr>.azurecr.io/<image-name>:latest` - Latest build

## ArgoCD Integration

The workflow uses the [cloudposse/github-action-deploy-argocd](https://github.com/cloudposse/github-action-deploy-argocd) action to trigger ArgoCD deployments.

### ArgoCD Cluster URL Format

For GitHub-based manifests repositories:
```
https://github.com/<org>/<repo>/blob/<branch>/<path-to-apps>
```

Example:
```
https://github.com/myorg/k8s-manifests/blob/main/clusters/production/apps
```

## Dockerfile Requirements

Each application must have a Dockerfile. Example for a .NET 8 application:

```dockerfile
FROM mcr.microsoft.com/dotnet/aspnet:8.0 AS base
WORKDIR /app
EXPOSE 8080

FROM mcr.microsoft.com/dotnet/sdk:8.0 AS build
WORKDIR /src
COPY ["MyApp.csproj", "./"]
RUN dotnet restore "MyApp.csproj"
COPY . .
RUN dotnet build "MyApp.csproj" -c Release -o /app/build

FROM build AS publish
RUN dotnet publish "MyApp.csproj" -c Release -o /app/publish

FROM base AS final
WORKDIR /app
COPY --from=publish /app/publish .
ENTRYPOINT ["dotnet", "MyApp.dll"]
```

## Infrastructure Changes

The workflow automatically detects infrastructure changes by checking if any files under `infra_path_prefix` have changed. You can force infrastructure deployment with `force_infra: true`.

## Troubleshooting

### Authentication Issues
- Ensure OIDC is configured between GitHub and Azure
- Verify Service Principal has appropriate permissions
- Check that AKS has permission to pull from ACR

### Build Failures
- Verify Dockerfile paths are correct
- Check .NET version matches project requirements
- Ensure all dependencies are available

### ArgoCD Deployment Issues
- Verify GITHUB_AUTH_PAT has access to manifests repository
- Check ArgoCD cluster URL format
- Ensure namespace exists in target cluster
- Review ArgoCD logs for sync errors

## Differences from Function Deployment

Compared to the `func-deploy-dotnet.yaml` workflow:
- Uses Docker/containerization instead of direct deployment
- Requires ACR for image storage
- Uses ArgoCD for GitOps-based deployment
- Deploys to Kubernetes instead of Azure Functions
- Images are tagged with git SHA for traceability
