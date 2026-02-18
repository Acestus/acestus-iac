# Azure Image Builder Wrapper Module

## Overview
This module wraps the AVM module `avm/ptn/virtual-machine-images/azure-image-builder` for Acestus deployments. Version: **1.0.0**

## Usage
```bicep
module azureImageBuilder 'modules-bicep/avm/ptn/virtual-machine-images/azure-image-builder/main.bicep' = {
  name: 'azureImageBuilder'
  params: {
    // Add parameters here
  }
}
```

## Implementation
- Uses AVM module version: `0.2.2`
- Opinionated wrapper for Acestus standards

## Security
- Follows Acestus security best practices

## Documentation
- See [AVM Azure Image Builder](https://github.com/Azure/avm/tree/main/ptn/virtual-machine-images/azure-image-builder)
