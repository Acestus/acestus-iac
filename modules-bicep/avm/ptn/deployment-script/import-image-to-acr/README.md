# Import Image to ACR Wrapper Module

## Overview
This module wraps the AVM module `avm/ptn/deployment-script/import-image-to-acr` for Acestus deployments. Version: **1.0.0**

## Usage
```bicep
module importImageToAcr 'modules-bicep/avm/ptn/deployment-script/import-image-to-acr/main.bicep' = {
  name: 'importImageToAcr'
  params: {
    // Add parameters here
  }
}
```

## Implementation
- Uses AVM module version: `0.4.4`
- Opinionated wrapper for Acestus standards

## Security
- Follows Acestus security best practices

## Documentation
- See [AVM Import Image to ACR](https://github.com/Azure/avm/tree/main/ptn/deployment-script/import-image-to-acr)
