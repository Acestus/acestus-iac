# AI Coding Guidelines for AKS .NET Template

This document provides guidelines for AI assistants working with this repository.

## Repository Overview

This is a .NET 8 AKS template repository with containerized Web API applications:
- **api-traffic**: Simple HTTP greeting API
- **time-logger**: Time logging application
- **fabric-sync**: File synchronization service

## Project Conventions

### Directory Structure
- Each application has its own directory with .NET project structure
- Infrastructure as Code lives in `infrastructure/`
- Kubernetes manifests live in `k8s/{app-name}/`
- Deployment scripts live in `scripts/`
- GitHub workflows live in `.github/workflows/`

### Naming Conventions
- **CAF Naming**: Follow Cloud Adoption Framework naming: `{projectName}-{environment}-{region}-{instanceNumber}`
- **AKS Clusters**: `aks-{project}-{env}-{region}-{instance}` (e.g., `aks-timelogger-prd-usw2-001`)
- **Container Registries**: `acr{project}{env}{region}{instance}` (lowercase, no hyphens)
- **Resource Groups**: `rg-{cafName}` (e.g., `rg-timelogger-prd-usw2-001`)
- **Deployment Stacks**: `stack-{cafName}` (e.g., `stack-timelogger-prd-usw2-001`)

### Tags
All Azure resources should include these tags:
```bicep
tags = {
  ManagedBy: '<your-repo-url>'
  CreatedBy: '{username}'
  Environment: '{Development|Production}'
  Subscription: '{subscription-name}'
  Project: '{project-description}'
  CAFName: '{cafName}'
}
```

## .NET Guidelines

### Version
- Use .NET 8.0 (LTS)
- Use C# 12 features where appropriate
- Enable nullable reference types

### Project Structure
```
{app-name}/
├── {AppName}.csproj       # Project file
├── Program.cs             # Application entry with minimal API
├── appsettings.json       # Configuration
├── appsettings.Development.json
└── Dockerfile
```

### Code Style - Minimal API
```csharp
var builder = WebApplication.CreateBuilder(args);

builder.Services.AddEndpointsApiExplorer();
builder.Services.AddHealthChecks();

var app = builder.Build();

// Health endpoints for Kubernetes
app.MapHealthChecks("/health/live");
app.MapHealthChecks("/health/ready");

// API endpoints
app.MapGet("/api/endpoint", (string? param) =>
{
    return Results.Ok(new { data = param });
});

app.Run();
```

### .csproj Configuration
```xml
<Project Sdk="Microsoft.NET.Sdk.Web">
  <PropertyGroup>
    <TargetFramework>net8.0</TargetFramework>
    <Nullable>enable</Nullable>
    <ImplicitUsings>enable</ImplicitUsings>
  </PropertyGroup>
</Project>
```

## Docker Guidelines

### Multi-Stage Dockerfile
```dockerfile
# Build stage
FROM mcr.microsoft.com/dotnet/sdk:8.0-alpine AS build
WORKDIR /src
COPY *.csproj ./
RUN dotnet restore
COPY . ./
RUN dotnet publish -c Release -o /app/publish --no-restore

# Runtime stage
FROM mcr.microsoft.com/dotnet/aspnet:8.0-alpine
WORKDIR /app
COPY --from=build /app/publish .

RUN addgroup -S appgroup && adduser -S appuser -G appgroup
USER appuser

EXPOSE 8080
ENV ASPNETCORE_URLS=http://+:8080

ENTRYPOINT ["dotnet", "AppName.dll"]
```

## Kubernetes Guidelines

### Deployment Configuration
- Use 2 replicas for high availability
- Set resource requests and limits appropriate for .NET
- Use ASP.NET Core health checks for probes

```yaml
resources:
  requests:
    memory: "128Mi"
    cpu: "100m"
  limits:
    memory: "256Mi"
    cpu: "250m"
livenessProbe:
  httpGet:
    path: /health/live
    port: 8080
  initialDelaySeconds: 10
readinessProbe:
  httpGet:
    path: /health/ready
    port: 8080
  initialDelaySeconds: 5
```

## Bicep Guidelines

### Style Guide
- One directory per resource group
- One workflow YAML per resource group
- Deploy with `az stack group create` (deployment stacks)
- Use `.bicepparam` files for environment-specific parameters

### Parameter Files
- Use `main.dev.bicepparam` for development
- Use `main.prd.bicepparam` for production
- Always use `using 'main.bicep'` directive

## Deployment Guidelines

### Infrastructure Deployment
Use Azure Deployment Stacks:
```powershell
.\scripts\deploy-infra.ps1 -Environment dev
```

### Application Deployment
Build and push images:
```powershell
.\scripts\deploy-apps.ps1 -Environment dev
```

## GitHub Actions

### Workflow Structure
- Trigger on push to main branch
- Use OIDC authentication with Azure
- Build and push images with matrix strategy
- Deploy to AKS

### Required Secrets/Variables
- `AZURE_CLIENT_ID`: Service Principal client ID
- `AZURE_SUBSCRIPTION_ID`: Target subscription
- `AZURE_TENANT_ID`: Azure AD tenant ID
- `RESOURCE_GROUP_NAME`: Target resource group

## Code Review Conventions

Use [Conventional Comments](https://conventionalcomments.org/):
- `issue (blocking): {description}` - Must be addressed
- `issue (non-blocking): {description}` - Should be addressed
- `suggestion: {description}` - Optional improvement
- `nitpick: {description}` - Minor style issue

## Security Best Practices

- Use Managed Identity for Azure service authentication
- Run containers as non-root user
- Use minimal base images (Alpine)
- Set resource limits to prevent DoS
- Enable HTTPS via ingress controller
- Keep dependencies updated

## Testing

### Local Development
```bash
cd {app-name}
dotnet run
```

### Local Docker Testing
```bash
docker build -t app-name:local .
docker run -p 8080:8080 app-name:local
```

### Running Tests
```bash
dotnet test
```
