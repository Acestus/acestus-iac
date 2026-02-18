# Time Logger - AKS .NET Template

A production-ready Azure Kubernetes Service (AKS) template featuring containerized .NET 8 applications with automated blob storage logging.

## Overview

This template demonstrates a complete AKS deployment with:

- **time-logger**: CronJob that writes timestamped logs to Azure Blob Storage
- **api-traffic**: Simple HTTP greeting API
- **fabric-sync**: Service for syncing files with external systems

## Architecture

```
┌─────────────────────────────────────────────────────────────────────┐
│                      Azure Kubernetes Service                        │
│  ┌────────────────┐  ┌────────────────┐  ┌────────────────┐        │
│  │  api-traffic   │  │  time-logger   │  │  fabric-sync   │        │
│  │  (Deployment)  │  │    (CronJob)   │  │  (Deployment)  │        │
│  └────────────────┘  └────────┬───────┘  └────────────────┘        │
└─────────────────────────────────┼──────────────────────────────────┘
                                  │
                                  ▼
                    ┌─────────────────────────┐
                    │  Azure Blob Storage     │
                    │  Containers:            │
                    │  - container-dev        │
                    │  - container-stg        │
                    │  - container-prd        │
                    └─────────────────────────┘
```

## Applications

| Application | Type | Description |
|-------------|------|-------------|
| `time-logger` | CronJob | Writes timestamped JSON logs to blob storage every minute |
| `api-traffic` | Deployment | HTTP API with health endpoints for testing |
| `fabric-sync` | Deployment | File synchronization service with resilience patterns |

## Environments

| Environment | Branch |
|-------------|--------|
| Development | `dev` |
| Staging | `stg` |
| Production | `prd` |

## Getting Started

### Prerequisites

- Azure CLI installed and logged in (`az login`)
- kubectl CLI installed
- Docker for building images
- Access to an Azure subscription

### Setup

1. Clone the repository:

   ```bash
   git clone <your-repo-url>
   cd time-logger
   ```

2. Update infrastructure parameters:
   - Edit `infrastructure/main.dev.bicepparam`
   - Set your project name, subscription, and resource details
   - Configure existing ACR or create a new one

3. Deploy infrastructure:

   ```powershell
   az stack group create \
     --name stack-<your-project>-dev-<region>-001 \
     --resource-group rg-<your-project>-dev-<region>-001 \
     --template-file infrastructure/main.bicep \
     --parameters infrastructure/main.dev.bicepparam \
     --deny-settings-mode none
   ```

4. Build and push container images (see deployment section)

## Deployment

### Infrastructure

Deploy Azure resources using Bicep:

```powershell
# Deploy to development
.\scripts\deploy-infra.ps1 -Environment dev

# Deploy to staging
.\scripts\deploy-infra.ps1 -Environment stg

# Deploy to production
.\scripts\deploy-infra.ps1 -Environment prd
```

### Applications

Build and push images, then deploy to AKS:

```powershell
# Manual deployment
.\scripts\deploy-local.ps1 -Environment dev

# Or use GitHub Actions (recommended)
# Push to dev/stg/prd branches triggers automated deployment
```

## CI/CD

GitHub Actions workflows handle automated deployments:

| Branch | Workflow | Environment |
|--------|----------|-------------|
| `dev` | `push-to-dev.yaml` | Development |
| `stg` | `push-to-stg.yaml` | Staging |
| `prd` | `push-to-prd.yaml` | Production |

### Required GitHub Secrets/Variables

Set these in your repository settings:

**Variables:**

- `AZURE_TENANT_ID`: Azure AD tenant ID
- `AZURE_CLIENT_ID`: Managed identity client ID
- `AZURE_SUBSCRIPTION_ID`: Target subscription ID

**Repository Details:**

- Resource group names
- AKS cluster names
- ACR registry name
- Storage account names

## Application Details

### time-logger

CronJob that writes timestamped JSON logs to blob storage every minute. Demonstrates:

- CronJob scheduling in Kubernetes
- Azure Storage SDK usage
- Secret management with Kubernetes Secrets
- Error handling and resilience

### api-traffic

Simple HTTP API with health endpoints. Demonstrates:

- ASP.NET Core Minimal APIs
- Health checks for Kubernetes
- Deployment with multiple replicas
- Container best practices

### fabric-sync

File synchronization service with built-in resilience patterns:

- HTTP resilience with Polly (retry, circuit breaker, timeout)
- RESTful API endpoints
- Token replacement for environment-specific configurations

## Development

### Local Testing

Build and run locally:

```bash
cd time-logger
dotnet run
```

Run in Docker:

```bash
docker build -t time-logger:local ./time-logger
docker run -e AZURE_STORAGE_CONNECTION_STRING="<connection-string>" time-logger:local
```

### Debugging in AKS

Use the debug pod for troubleshooting:

```bash
kubectl apply -f k8s/debug/debug-pod.yaml
kubectl exec -it debug-pod -- sh
```

## Optional Folders

This repository includes several optional folders that are **not required** for the core time-logger template:

### stacks-bicep/ and stacks-terraform/

Example infrastructure deployment stacks from the original organization. These contain:

- Company-specific subscription IDs, resource names, and configurations
- Various deployment patterns and examples
- **Action**: Review `stacks-bicep/README-TEMPLATE.md` and `stacks-terraform/README-TEMPLATE.md`
- **Recommendation**: Delete these folders if you only need the core template

### modules-bicep/ and modules-terraform/

Reusable infrastructure modules with company branding. These contain:

- Custom wrappers around Azure Verified Modules
- Organization-specific naming and patterns
- **Action**: Review `modules-bicep/README-TEMPLATE.md` and `modules-terraform/README-TEMPLATE.md`
- **Recommendation**: Delete these folders and use [Azure Verified Modules](https://azure.github.io/Azure-Verified-Modules/) directly

The core template in `/infrastructure`, `/k8s`, and `.github/workflows` has been sanitized and is ready to use.

## Contributing

1. Create a feature branch from `dev`
2. Make changes and test locally
3. Create PR to merge into `dev`
4. After approval, merge to `stg` for staging tests
5. Finally merge to `prd` for production deployment
