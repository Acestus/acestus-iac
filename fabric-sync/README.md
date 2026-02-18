# Fabric Sync

A .NET 8 minimal API service that syncs Fabric workspace items from GitHub using token replacement for environment-specific configurations.

## Overview

This service solves the problem of deploying Fabric items (pipelines, copyjobs) across multiple environments (dev, stg, prd) where each environment has different logicalIds for lakehouses, notebooks, and other dependencies.

**How it works:**

1. Reads item definitions from GitHub (pipeline-content.json, copyjob-content.json)
2. Replaces tokens (e.g., `{{LH_API_BRZ}}`) with environment-specific logicalIds from mapping files
3. Pushes resolved definitions directly to Fabric via the `updateDefinition` REST API

This bypasses Fabric's Git sync feature entirely, allowing clean token-based templates in Git.

## Endpoints

| Method | Endpoint | Description |
|--------|----------|-------------|
| POST | `/sync/{environment}` | Sync items for dev, stg, or prd |
| POST | `/webhook/github` | GitHub webhook for automatic sync |
| GET | `/health/live` | Kubernetes liveness probe |
| GET | `/health/ready` | Kubernetes readiness probe |

## Configuration

### appsettings.json

```json
{
  "GitHub": {
    "Owner": "<your-github-org>",
    "Repo": "<your-repo-name>",
    "Token": ""  // Set via environment variable or K8s secret
  },
  "Fabric": {
    "Workspaces": {
      "Dev": "<your-dev-workspace-id>",
      "Stg": "<your-stg-workspace-id>",
      "Prd": "<your-prd-workspace-id>"
    }
  }
}
```

### Environment Variables

| Variable | Description |
|----------|-------------|
| `GitHub__Token` | GitHub PAT with repo read access |

## Token Mapping Files

Store environment-specific logicalIds in `.fabric/mappings-{env}.json`:

```json
{
  "LH_API_BRZ": "1d0ab46e-eeb0-88d0-4395-221d9ff4c31a",
  "LH_API_SLV": "41b08fe4-ca5c-91ba-4264-7f0e19f2860e",
  "NB_TFM_ESS_BRZ_SLV": "bad18466-9227-8822-4ad7-2d796ff425cf",
  "NB_TFM_ESS_SLV_GLD": "4b472aae-88fb-a8aa-422c-1f3b2168e9cb"
}
```

## Local Development

```bash
# Navigate to the app directory
cd fabric-sync

# Restore packages
dotnet restore

# Run the app
dotnet run

# Test sync endpoint
curl -X POST http://localhost:5000/sync/dev \
  -H "Content-Type: application/json" \
  -d '{"branch": "dev"}'
```

## Kubernetes Deployment

```bash
# Create secret for GitHub token
kubectl create secret generic fabric-sync-secrets \
  --from-literal=github-token=YOUR_GITHUB_PAT

# Apply manifests
kubectl apply -f k8s/fabric-sync/

# Check deployment
kubectl get pods -l app=fabric-sync
```

### Workload Identity

The app uses Azure Workload Identity to authenticate with Fabric. Ensure:

1. The AKS cluster has workload identity enabled
2. A User-Assigned Managed Identity is created with Fabric API permissions
3. The ServiceAccount is annotated with the identity's client ID
4. The Managed Identity has Admin access on target Fabric workspaces

## Authentication

- **Fabric API**: Uses `Azure.Identity.DefaultAzureCredential`
  - In AKS: Workload Identity (Managed Identity)
  - Local: Azure CLI (`az login`)
- **GitHub API**: Uses a Personal Access Token (PAT) with `repo` scope

## Adding New Tokens

1. Add the token placeholder in the item definition (e.g., `{{NEW_TOKEN}}`)
2. Add the mapping to each environment's mapping file
3. The token will be replaced during sync

## Troubleshooting

### "Item not found in Fabric workspace"

- Check that the logicalId in `.platform` exists in the target workspace
- The item may need to be created in Fabric first via Git sync or manually

### "401 Unauthorized"

- Ensure the Managed Identity has Fabric API permissions
- Check that the workspace Admin role is assigned to the identity

### "GitHub API error"

- Verify the GitHub PAT is valid and has repo access
- Check the repository and branch names in configuration
