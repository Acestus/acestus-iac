# Deployment Parameters

This folder contains environment-specific parameter files for Microsoft Fabric deployment pipelines, following a pattern similar to Bicep parameter files.

## File Naming Convention

| File | Branch | Environment |
|------|--------|-------------|
| `parameters.dev.json` | `dev` | Development |
| `parameters.stg.json` | `stg` | Staging |
| `parameters.prd.json` | `prd` | Production |

## Structure

Each parameter file contains:

- **rules**: Override values applied to specific Fabric items during deployment
- **parameters**: Environment-specific variable values for pipelines
- **notebookParameters**: Environment-specific values for notebooks

## Environment Configuration

All environments use the same storage account with different containers:

| Environment | Container | Lakehouse |
|-------------|-----------|-----------|
| Development | `container-development` | `ws-fabric-dev/lh_api_brz` |
| Staging | `container-staging` | `ws-fabric-stg/lh_api_brz` |
| Production | `container-production` | `ws-fabric-prd/lh_api_brz` |

## Notebook Parameters

Notebooks use a tagged parameters cell that can be overridden at runtime. Parameters include:

| Parameter | Description | Dev | Stg | Prd |
|-----------|-------------|-----|-----|-----|
| `environment` | Environment identifier | `dev` | `stg` | `prd` |
| `source_container` | Blob container name | `container-development` | `container-staging` | `container-production` |
| `storage_account` | Storage account name | `<your-storage-account>` | `<your-storage-account>` | `<your-storage-account>` |
| `timezone` | Local timezone | `<your-timezone>` | `<your-timezone>` | `<your-timezone>` |

### Passing Parameters from Pipeline

When calling notebooks from a pipeline, pass parameters like this:

```json
{
  "type": "TridentNotebook",
  "typeProperties": {
    "notebookId": "...",
    "parameters": {
      "environment": { "value": "stg", "type": "string" },
      "source_container": { "value": "container-staging", "type": "string" }
    }
  }
}
```

## Usage

### Option 1: Fabric Deployment Pipeline UI

1. In Fabric, go to **Deployment Pipelines**
2. Select your pipeline → **Deployment rules**
3. Import rules from the appropriate parameter file
4. Values from `overrides` will be applied during stage promotion

### Option 2: Fabric REST API / CI/CD

Use the Fabric REST API to apply deployment rules programmatically:

```powershell
# Example: Apply staging rules via API
$rules = Get-Content ".deployment/parameters.stg.json" | ConvertFrom-Json
# Call Fabric Deployment Pipeline API with rules
```

### Option 3: Azure DevOps / GitHub Actions

Reference the parameter files in your CI/CD pipeline:

```yaml
# Azure DevOps example
- task: PowerShell@2
  inputs:
    targetType: inline
    script: |
      $env = "$(Environment)"
      $params = Get-Content "ws-fabric/.deployment/parameters.$env.json" | ConvertFrom-Json
      # Apply deployment rules via Fabric API
```

## Updating Parameters

When adding new items that require environment-specific values:

1. Add the item to the `rules` array in each parameter file
2. Specify the JSON path to the property and its environment-specific value
3. Test in Development before promoting to Staging/Production

## Current Parameterized Items

| Item | Type | Parameterized Properties |
|------|------|--------------------------|
| `pl_ing_blob_api_brz` | DataPipeline | Storage endpoint, Managed Identity, Trigger scope |
