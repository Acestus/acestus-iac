# Bicep Modules for Acestus Infrastructure

This directory contains reusable Bicep modules for Azure resource deployments.

## Scripts

Module management scripts are located in the `../scripts/` folder:

- **Publish-BicepModule.ps1**: Publishes Bicep modules to ACR with version management
- **Publish-AllModules.ps1**: Batch publishes all modules in the modules directory
- **List-ModuleVersions.ps1**: Lists published module versions in ACR
- **Test-Module.ps1**: Validates module syntax and runs tests

## Usage

### Publishing a Single Module
```powershell
cd scripts
.\Publish-BicepModule.ps1 -ModuleName "storage-account" -Version "v1.0.0"
```

### Publishing All Modules
```powershell
cd scripts
.\Publish-AllModules.ps1 -Version "v1.0.0"
```

### Testing a Module
```powershell
cd scripts
.\Test-Module.ps1 -ModuleName "storage-account"
```

## Module Versioning

- Use semantic versioning (e.g., v1.0.0, v1.1.0, v2.0.0)
- Major version changes for breaking changes
- Minor version changes for new features
- Patch version changes for bug fixes

## Prerequisites

- Azure CLI installed and authenticated
- Access to the Acestus ACR (acracemgtcrprdwus3001)
- AcrPush permissions on the container registry