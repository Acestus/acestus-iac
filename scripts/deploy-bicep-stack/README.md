# Bicep Deployment Script

Small .NET 10 console app for deploying a Bicep stack with the Azure CLI.

## Example

```bash
dotnet run --project scripts/deploy-bicep-stack -- \
  --stack-path stacks-bicep/rg-crm-dev \
  --resource-group rg-crm-dev
```

## What-if

```bash
dotnet run --project scripts/deploy-bicep-stack -- \
  --stack-path stacks-bicep/rg-crm-dev \
  --resource-group rg-crm-dev \
  --what-if
```
