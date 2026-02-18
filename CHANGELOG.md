# Changelog

All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.1.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [Unreleased]

### Template Features

- **AKS Infrastructure** - Complete Bicep templates for Azure Kubernetes Service deployment
  - Configurable node pools with auto-scaling
  - Azure Container Registry integration
  - Log Analytics and Application Insights monitoring
  - Support for dev, staging, and production environments
- **time-logger Application** - Kubernetes CronJob that writes timestamped JSON logs to Azure Blob Storage
  - Runs every minute
  - Writes to environment-specific containers
  - Resilient error handling with automatic retry
- **api-traffic Application** - Simple HTTP greeting API
  - Health check endpoints for Kubernetes probes
  - GET and POST endpoints
  - Application Insights telemetry
- **fabric-sync Application** - File synchronization service with resilience patterns
  - HTTP resilience with Polly-based handlers
  - Retry policy: 3 attempts with exponential backoff (2s base delay)
  - Circuit breaker: Opens at 50% failure ratio, 30s break duration
  - Timeout: 30s per request
- **Docker Images** - Hardened chiseled (distroless) images
  - `mcr.microsoft.com/dotnet/aspnet:8.0-jammy-chiseled` (fabric-sync, api-traffic)
  - `mcr.microsoft.com/dotnet/runtime:8.0-jammy-chiseled` (time-logger)
  - No shell, curl, or wget - enhanced security posture
- **GitHub Actions Workflows** - Automated CI/CD for all environments
  - Build and push container images to ACR
  - Deploy to AKS clusters
  - OIDC authentication (passwordless)
- **Kubernetes Manifests** - Production-ready configurations
  - Deployments with health checks
  - Services (LoadBalancer)
  - CronJobs with secret management
  - Debug pod for troubleshooting
- **Azure.Security.KeyVault.Secrets** - NuGet package removed
- **GitHubService.cs** - GitHub API client removed
- **sm_api_time.SemanticModel** - Removed from sync (not supported)

### Security

- Container images use non-root users
- Chiseled base images for reduced attack surface
- Kubernetes secrets for sensitive data
- OIDC authentication for Azure (no stored credentials)

## [0.3.0] - 2026-02-16

### Added

- **fabric-sync App** - .NET 8 Kubernetes app for Fabric workspace synchronization
  - Receives Fabric item definitions from GitHub Actions (`ws-fabric/` folder)
  - Replaces `{{TOKEN}}` placeholders with environment-specific logicalIds
  - Pushes definitions to Fabric via REST API (updateDefinition)
  - Dynamic discovery of all Fabric artifacts (no hardcoded item lists)
  - Uses managed identity for Azure/Fabric authentication
- **Token Mapping Files** - Environment-specific logicalId mappings
  - `.fabric/mappings-dev.json` - Development workspace IDs
  - `.fabric/mappings-stg.json` - Staging workspace IDs
  - `.fabric/mappings-prd.json` - Production workspace IDs
- **GitHub Actions Workflows** - Trigger fabric-sync on push
  - `fabric-sync-dev.yml` - Development (dev branch)
  - `fabric-sync-stg.yml` - Staging (stg branch)
  - `fabric-sync-prd.yml` - Production (prd branch)
- **Kubernetes Manifests** - fabric-sync deployment (`k8s/fabric-sync/`)
- **Architecture Diagram** - PlantUML diagram at `docs/api-architecture.puml`
- **CI/CD Documentation** - Setup guide in `.github/CICD_SETUP.md`

### Removed

- **argocd/** folder - ArgoCD configuration no longer needed

## [0.2.0] - 2026-02-15

### Added

- **Ingestion Pipeline** (`pl_ing_api_brz`) - Copies JSON data from Azure Blob Storage to Bronze lakehouse
  - Source: `stapidevusw2001/container-development`
  - Destination: `lh_api_brz.dbo.time_logs`
  - Uses workspace identity authentication
- **Deployment Parameters** - Environment-specific configuration files
  - `parameters.dev.json` - Development (container-development)
  - `parameters.stg.json` - Staging (container-staging)
  - `parameters.prd.json` - Production (container-production)
- **Notebook Parameters** - Added parameterized cells to all notebooks
  - `nb_tfm_api_brz_slv` - environment, source_container, storage_account
  - `nb_tfm_api_slv_gld` - environment, source_container, storage_account, timezone
  - `nb_api_scripts` - environment, source_container, storage_account, workspace_id, lakehouse_gld_id
- **Repository Governance**
  - `.gitignore` - Exclude temp files, secrets, Python cache
  - `CODEOWNERS` - PR review requirements by team/artifact type
  - `pull_request_template.md` - Standardized PR checklist
  - `README.md` - Architecture diagram, setup instructions, data flow documentation

### Changed

- Updated all notebooks to use parameterized values instead of hardcoded IDs
- Simplified environment configuration - all environments use same storage account with different containers

### Configuration Notes

This template requires environment-specific configuration for:

- Azure Storage Account (created by infrastructure deployment)
- Azure Subscription and Resource Group
- Microsoft Fabric Workspace IDs (if using fabric-sync)
- Managed Identity for workspace access

## [0.1.0] - 2026-02-14

### Added

- Initial workspace structure with medallion architecture
- **Lakehouses**
  - `lh_api_brz` - Bronze (raw data)
  - `lh_api_slv` - Silver (cleansed data)
  - `lh_api_gld` - Gold (business-ready data)
- **Transformation Pipelines**
  - `pl_tfm_api_brz_slv` - Bronze to Silver transformation
  - `pl_tfm_api_slv_gld` - Silver to Gold transformation
- **Notebooks**
  - `nb_tfm_api_brz_slv` - Bronze to Silver logic
  - `nb_tfm_api_slv_gld` - Silver to Gold logic (adds local timestamps)
  - `nb_api_scripts` - Utility scripts
- **Semantic Model**
  - `sm_api_time` - Power BI dataset exposing `time_logs` table
- **Other Items**
  - `ai_api_analytics.DataAgent` - Data agent configuration
  - `spark_api_slv_gld.SparkJobDefinition` - Spark job for Silver to Gold
  - `func_api_*` - User data functions

### Infrastructure

- Deployment pipeline: Development → Staging → Production
- Git integration with branch-per-environment strategy
  - `dev` branch → ws-fabric-dev
  - `stg` branch → ws-fabric-stg
  - `prd` branch → ws-fabric-prd

---

[Unreleased]: https://github.com/<your-org>/<your-repo>/compare/v0.3.0...HEAD
[0.3.0]: https://github.com/<your-org>/<your-repo>/compare/v0.2.0...v0.3.0
[0.2.0]: https://github.com/<your-org>/<your-repo>/compare/v0.1.0...v0.2.0
[0.1.0]: https://github.com/<your-org>/<your-repo>/releases/tag/v0.1.0
