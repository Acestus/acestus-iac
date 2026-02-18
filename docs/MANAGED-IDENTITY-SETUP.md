# Managed Identity Setup for GitHub Actions

This document describes how to configure a User-assigned Managed Identity (UMI) for GitHub Actions deployments using OIDC authentication.

## Overview

GitHub Actions workflows authenticate to Azure using OpenID Connect (OIDC) through a user-assigned managed identity. This eliminates the need to store credentials as secrets, providing a more secure authentication method.

## Prerequisites

- Azure subscription
- Resource group for the application
- User-assigned managed identity
- GitHub repository with Actions enabled

## Step 1: Create User-Assigned Managed Identity

```bash
# Create the managed identity
az identity create \
  --name "umi-<project>-<env>-<region>-<seq>" \
  --resource-group "rg-<project>-<env>-<region>-<seq>" \
  --location "<region>"

# Get the client ID (you'll need this for GitHub variables)
az identity show \
  --name "umi-<project>-<env>-<region>-<seq>" \
  --resource-group "rg-<project>-<env>-<region>-<seq>" \
  --query clientId \
  --output tsv
```

**Example:**

```bash
az identity create \
  --name "umi-myproject-prd-swc-001" \
  --resource-group "rg-myproject-prd-swc-001" \
  --location "westus2"
```

## Step 2: Configure Federated Identity Credentials (OIDC)

Federated credentials allow GitHub Actions to authenticate as the managed identity.

### For Environment-Based Deployment

```bash
az identity federated-credential create \
  --name "github-<org>-<repo>-env-<environment>" \
  --identity-name "umi-<project>-<env>-<region>-<seq>" \
  --resource-group "rg-<project>-<env>-<region>-<seq>" \
  --issuer "https://token.actions.githubusercontent.com" \
  --subject "repo:<org>/<repo>:environment:<environment>" \
  --audiences "api://AzureADTokenExchange"
```

**Example:**

```bash
az identity federated-credential create \
  --name "github-your-org-your-repo-env-prd" \
  --identity-name "umi-myproject-prd-swc-001" \
  --resource-group "rg-myproject-prd-swc-001" \
  --issuer "https://token.actions.githubusercontent.com" \
  --subject "repo:your-org/your-repo:environment:prd" \
  --audiences "api://AzureADTokenExchange"
```

### For Branch-Based Deployment

If your workflow doesn't use GitHub environments:

```bash
az identity federated-credential create \
  --name "github-<org>-<repo>-<branch>" \
  --identity-name "umi-<project>-<env>-<region>-<seq>" \
  --resource-group "rg-<project>-<env>-<region>-<seq>" \
  --issuer "https://token.actions.githubusercontent.com" \
  --subject "repo:<org>/<repo>:ref:refs/heads/<branch>" \
  --audiences "api://AzureADTokenExchange"
```

**Example:**

```bash
az identity federated-credential create \
  --name "github-your-org-your-repo-main" \
  --identity-name "umi-myproject-prd-swc-001" \
  --resource-group "rg-myproject-prd-swc-001" \
  --issuer "https://token.actions.githubusercontent.com" \
  --subject "repo:your-org/your-repo:ref:refs/heads/main" \
  --audiences "api://AzureADTokenExchange"
```

### Key Parameters

| Parameter | Description | Example |
|-----------|-------------|---------|
| `--issuer` | Always use GitHub's token endpoint | `https://token.actions.githubusercontent.com` |
| `--subject` | Specifies which GitHub context can use this identity | `repo:org/repo:environment:prd` |
| `--audiences` | Always use Azure's OIDC audience | `api://AzureADTokenExchange` |

## Step 3: Assign Azure Roles

The managed identity needs permissions to manage Azure resources.

### Subscription-Level Permissions (Recommended)

```bash
# Get the managed identity's client ID
CLIENT_ID=$(az identity show \
  --name "umi-<project>-<env>-<region>-<seq>" \
  --resource-group "rg-<project>-<env>-<region>-<seq>" \
  --query clientId \
  --output tsv)

# Assign Contributor role at subscription level
az role assignment create \
  --assignee "$CLIENT_ID" \
  --role "Contributor" \
  --scope "/subscriptions/<subscription-id>"
```

**Example:**

```bash
CLIENT_ID="b4232ee9-b8f9-416a-a972-7e35ea06f6f5"

az role assignment create \
  --assignee "$CLIENT_ID" \
  --role "Contributor" \
  --scope "/subscriptions/8b67b073-f765-482f-82ad-ede639aef462"
```

### Required Roles

| Role | Purpose | Scope | Required? |
|------|---------|-------|-----------|
| **Contributor** | Create, update, delete resources | Subscription | ✅ Yes |
| **User Access Administrator** | Manage role assignments (if using deployment stacks with deny assignments) | Subscription | ⚠️ Optional |
| **Azure Deployment Stack Owner** | Manage deployment stacks | Subscription | ⚠️ Optional |
| **AcrPull** | Pull Docker images from Azure Container Registry | ACR Resource | ✅ For AKS deployments |
| **AcrPush** | Push Docker images to Azure Container Registry | ACR Resource | ✅ For AKS deployments |
| **Azure Kubernetes Service Cluster User Role** | Get AKS credentials and deploy with kubectl | AKS Resource | ✅ For AKS deployments |
| **Log Analytics Contributor** | Access shared Log Analytics workspace for AKS monitoring | Log Analytics Workspace | ✅ For AKS with shared LAW |

### Additional Roles for Specific Scenarios

#### Azure Functions Deployments

When deploying Azure Functions that reference existing resources (Application Insights, App Service Plans) from other resource groups:

```bash
# Reader role - to read existing resources across subscription
az role assignment create \
  --assignee "$CLIENT_ID" \
  --role "Reader" \
  --scope "/subscriptions/<subscription-id>"

# Storage Blob Data Contributor - for function app storage access
az role assignment create \
  --assignee "$CLIENT_ID" \
  --role "Storage Blob Data Contributor" \
  --scope "/subscriptions/<subscription-id>"

# Storage Account Contributor - for storage account operations
az role assignment create \
  --assignee "$CLIENT_ID" \
  --role "Storage Account Contributor" \
  --scope "/subscriptions/<subscription-id>"
```

**Example:**

```bash
CLIENT_ID="b4232ee9-b8f9-416a-a972-7e35ea06f6f5"
SUBSCRIPTION_ID="8b67b073-f765-482f-82ad-ede639aef462"

# Grant Reader access for reading existing resources
az role assignment create \
  --assignee "$CLIENT_ID" \
  --role "Reader" \
  --scope "/subscriptions/$SUBSCRIPTION_ID"

# Grant Storage Blob Data Contributor for function storage
az role assignment create \
  --assignee "$CLIENT_ID" \
  --role "Storage Blob Data Contributor" \
  --scope "/subscriptions/$SUBSCRIPTION_ID"

# Grant Storage Account Contributor for storage operations
az role assignment create \
  --assignee "$CLIENT_ID" \
  --role "Storage Account Contributor" \
  --scope "/subscriptions/$SUBSCRIPTION_ID"
```

**Why these roles are needed:**

- **Reader**: Allows the deployment to reference existing Application Insights instances and App Service Plans from other resource groups
- **Storage Blob Data Contributor**: Required for Functions runtime to access blob storage for deployment packages and file shares
- **Storage Account Contributor**: Required for Functions to manage storage account configurations and keys

#### AKS and Container Deployments

When deploying containerized applications to AKS with Azure Container Registry (ACR):

```bash
# AcrPull - to pull images from ACR
az role assignment create \
  --assignee "$CLIENT_ID" \
  --role "AcrPull" \
  --scope "/subscriptions/<acr-subscription-id>/resourceGroups/<acr-resource-group>/providers/Microsoft.ContainerRegistry/registries/<acr-name>"

# AcrPush - to push built images to ACR
az role assignment create \
  --assignee "$CLIENT_ID" \
  --role "AcrPush" \
  --scope "/subscriptions/<acr-subscription-id>/resourceGroups/<acr-resource-group>/providers/Microsoft.ContainerRegistry/registries/<acr-name>"

# Azure Kubernetes Service Cluster User Role - for getting AKS credentials
az role assignment create \
  --assignee "$CLIENT_ID" \
  --role "Azure Kubernetes Service Cluster User Role" \
  --scope "/subscriptions/<subscription-id>/resourceGroups/<resource-group>/providers/Microsoft.ContainerService/managedClusters/<aks-cluster-name>"

# Log Analytics Contributor - for AKS to access shared Log Analytics workspace
az role assignment create \
  --assignee "$CLIENT_ID" \
  --role "Log Analytics Contributor" \
  --scope "/subscriptions/<law-subscription-id>/resourceGroups/<law-resource-group>/providers/Microsoft.OperationalInsights/workspaces/<law-name>"
```

**Example:**

```bash
CLIENT_ID="<your-managed-identity-client-id>"
ACR_SUBSCRIPTION_ID="<your-acr-subscription-id>"
SUBSCRIPTION_ID="<your-app-subscription-id>"
LAW_SUBSCRIPTION_ID="<your-monitoring-subscription-id>"

# Grant AcrPull for pulling images during deployment
az role assignment create \
  --assignee "$CLIENT_ID" \
  --role "AcrPull" \
  --scope "/subscriptions/$ACR_SUBSCRIPTION_ID/resourceGroups/rg-acr-dev-swc-001/providers/Microsoft.ContainerRegistry/registries/acrcompanydevswc001"

# Grant AcrPush for pushing built images
az role assignment create \
  --assignee "$CLIENT_ID" \
  --role "AcrPush" \
  --scope "/subscriptions/$ACR_SUBSCRIPTION_ID/resourceGroups/rg-acr-dev-swc-001/providers/Microsoft.ContainerRegistry/registries/acrcompanydevswc001"

# Grant AKS cluster access for kubectl operations
az role assignment create \
  --assignee "$CLIENT_ID" \
  --role "Azure Kubernetes Service Cluster User Role" \
  --scope "/subscriptions/$SUBSCRIPTION_ID/resourceGroups/rg-myapp-dev-swc-001/providers/Microsoft.ContainerService/managedClusters/aks-myapp-dev-swc-001"

# Grant Log Analytics workspace access for AKS monitoring
az role assignment create \
  --assignee "$CLIENT_ID" \
  --role "Log Analytics Contributor" \
  --scope "/subscriptions/$LAW_SUBSCRIPTION_ID/resourceGroups/rg-monitoring/providers/Microsoft.OperationalInsights/workspaces/law-monitoring"
```

**Why these roles are needed:**

- **AcrPull**: Allows the workflow to authenticate and pull images from ACR
- **AcrPush**: Required for CI/CD workflows to push newly built Docker images to ACR
- **Azure Kubernetes Service Cluster User Role**: Required to run `az aks get-credentials` and deploy to the cluster with kubectl
- **Log Analytics Contributor**: Required when AKS uses a shared Log Analytics workspace in a different subscription for monitoring/diagnostics

**Note:** ACR and Log Analytics Workspace may be in different subscriptions (shared services subscriptions) while AKS is in the application subscription.

### Alternative: Resource Group-Level Permissions

For more restricted access, assign roles at the resource group level:

```bash
az role assignment create \
  --assignee "$CLIENT_ID" \
  --role "Contributor" \
  --scope "/subscriptions/<subscription-id>/resourceGroups/<resource-group-name>"
```

**Note:** This limits the identity to only manage resources within that specific resource group.

## Step 4: Configure GitHub Variables

Set these variables in your GitHub organization or repository.

### Organization Variables (Recommended)

```bash
# Set organization-level variables (requires admin:org scope)
gh auth refresh -h github.com -s admin:org

gh variable set UMI_<PROJECT>_<ENV>_<REGION>_<SEQ> \
  --org <org-name> \
  --body "<client-id>"

gh variable set AZURE_TENANT_ID \
  --org <org-name> \
  --body "<tenant-id>"

gh variable set <PROJECT>_<SUBSCRIPTION_NAME> \
  --org <org-name> \
  --body "<subscription-id>"
```

**Example:**

```bash
gh variable set UMI_MYPROJECT_PRD_swc_001 \
  --org your-org \
  --body "<your-client-id>"

gh variable set AZURE_TENANT_ID \
  --org your-org \
  --body "<your-tenant-id>"

gh variable set AZURE_SUBSCRIPTION_ID \
  --org your-org \
  --body "<your-subscription-id>"
```

### Repository Variables (Alternative)

```bash
gh variable set <VARIABLE_NAME> \
  --repo <org>/<repo> \
  --body "<value>"
```

## Step 5: Use in GitHub Actions Workflow

```yaml
name: Deploy to Azure

on:
  push:
    branches: [main]
  workflow_dispatch:

permissions:
  id-token: write  # Required for OIDC
  contents: read

jobs:
  deploy:
    runs-on: ubuntu-latest
    environment: prd  # Use if you configured environment-based credentials
    steps:
      - name: Checkout
        uses: actions/checkout@v4

      - name: Azure Login with OIDC
        uses: azure/login@v2
        with:
          client-id: ${{ vars.UMI_PROJECT_ENV_REGION_SEQ }}
          tenant-id: ${{ vars.AZURE_TENANT_ID }}
          subscription-id: ${{ vars.PROJECT_SUBSCRIPTIONNAME }}

      - name: Deploy resources
        run: |
          az group show --name rg-project-env-region-seq
```

## Validation

### Verify Federated Credentials

```bash
az identity federated-credential list \
  --identity-name "umi-<project>-<env>-<region>-<seq>" \
  --resource-group "rg-<project>-<env>-<region>-<seq>" \
  --output table
```

### Verify Role Assignments

```bash
# Get the principal ID
PRINCIPAL_ID=$(az identity show \
  --name "umi-<project>-<env>-<region>-<seq>" \
  --resource-group "rg-<project>-<env>-<region>-<seq>" \
  --query principalId \
  --output tsv)

# List role assignments
az role assignment list \
  --assignee "$PRINCIPAL_ID" \
  --all \
  --output table
```

### Verify GitHub Variables

```bash
gh variable list --org <org-name>
# or
gh variable list --repo <org>/<repo>
```

## Troubleshooting

### Common Errors

#### Error: "No matching federated identity record found"

**Cause:** The federated credential subject doesn't match the GitHub workflow context.

**Solution:**

- Verify the subject matches your workflow (environment vs branch)
- Ensure the organization and repository names are correct
- Check if you're using a GitHub environment and the credential is configured for it

#### Error: "The client has no configured federated identity credentials"

**Cause:** No federated credentials configured for the managed identity.

**Solution:** Follow Step 2 to create federated credentials.

#### Error: "No subscriptions found"

**Cause:** The managed identity doesn't have any role assignments.

**Solution:** Follow Step 3 to assign appropriate roles.

#### Error: "AuthorizationFailed"

**Cause:** The managed identity lacks necessary permissions.

**Solution:**

- Verify role assignments are correct
- Check the scope of the role assignment
- Wait a few minutes for role assignments to propagate

## Security Best Practices

1. **Use Environments:** Configure GitHub environments for production deployments with protection rules
2. **Least Privilege:** Only grant roles necessary for the deployment
3. **Scope Limitation:** Use resource group-level permissions when possible
4. **Audit:** Regularly review federated credentials and role assignments
5. **Rotation:** While OIDC tokens are short-lived, review and update configurations periodically

## Naming Conventions

### Managed Identity

- Format: `umi-<project>-<env>-<region>-<seq>`
- Example: `umi-myproject-prd-swc-001`

### Federated Credential

- Format: `github-<org>-<repo>-env-<environment>` or `github-<org>-<repo>-<branch>`
- Example: `github-your-org-your-repo-env-prd`

### GitHub Variables

- Format: `UMI_<PROJECT>_<ENV>_<REGION>_<SEQ>`
- Example: `UMI_MYPROJECT_PRD_swc_001`

## References

- [Azure Login Action Documentation](https://github.com/Azure/login)
- [Azure Workload Identity Federation](https://learn.microsoft.com/entra/workload-id/workload-identity-federation)
- [GitHub OIDC Documentation](https://docs.github.com/en/actions/deployment/security-hardening-your-deployments/about-security-hardening-with-openid-connect)
- [Azure Managed Identities](https://learn.microsoft.com/azure/active-directory/managed-identities-azure-resources/overview)

## Complete Example

Here's a complete setup for the dashboard-edm project:

```bash
# 1. Create managed identity
az identity create \
  --name "umi-myproject-prd-swc-001" \
  --resource-group "rg-myproject-prd-swc-001" \
  --location "westus2"

# 2. Configure OIDC
az identity federated-credential create \
  --name "github-your-org-your-repo-env-prd" \
  --identity-name "umi-myproject-prd-swc-001" \
  --resource-group "rg-myproject-prd-swc-001" \
  --issuer "https://token.actions.githubusercontent.com" \
  --subject "repo:your-org/your-repo:environment:prd" \
  --audiences "api://AzureADTokenExchange"

# 3. Assign roles
az role assignment create \
  --assignee "<your-client-id>" \
  --role "Contributor" \
  --scope "/subscriptions/<your-subscription-id>"

# 3a. Additional roles for Azure Functions (if needed)
az role assignment create \
  --assignee "<your-client-id>" \
  --role "Reader" \
  --scope "/subscriptions/<your-subscription-id>"

az role assignment create \
  --assignee "<your-client-id>" \
  --role "Storage Blob Data Contributor" \
  --scope "/subscriptions/<your-subscription-id>"

az role assignment create \
  --assignee "<your-client-id>" \
  --role "Storage Account Contributor" \
  --scope "/subscriptions/<your-subscription-id>"

# 4. Set GitHub variables
gh variable set UMI_MYPROJECT_PRD_swc_001 --org your-org --body "<your-client-id>"
gh variable set AZURE_TENANT_ID --org your-org --body "<your-tenant-id>"
gh variable set AZURE_SUBSCRIPTION_ID --org your-org --body "<your-subscription-id>"
```
