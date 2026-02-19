# AKS Wrapper Module

## Overview
This module wraps the AVM module `avm/ptn/azd/aks` for Acestus deployments. Version: **1.0.0**

## Usage
```bicep
module aks 'modules-bicep/avm/ptn/azd/aks/main.bicep' = {
  name: 'aks'
  params: {
    // Add parameters here
  }
}
```

## Implementation
- Uses AVM module version: `0.2.0`
- Opinionated wrapper for Acestus standards

## Security
- Follows Acestus security best practices

## Documentation
- See [AVM AKS](https://github.com/Azure/avm/tree/main/ptn/azd/aks)
