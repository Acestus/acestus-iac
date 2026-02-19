# ACR Container App Wrapper Module

## Overview
This module wraps the AVM module `avm/ptn/azd/acr-container-app` for Acestus deployments. Version: **1.0.0**

## Usage
```bicep
module acrContainerApp 'modules-bicep/avm/ptn/azd/acr-container-app/main.bicep' = {
  name: 'acrContainerApp'
  params: {
    // Add parameters here
  }
}
```

## Implementation
- Uses AVM module version: `0.4.0`
- Opinionated wrapper for Acestus standards

## Security
- Follows Acestus security best practices

## Documentation
- See [AVM ACR Container App](https://github.com/Azure/avm/tree/main/ptn/azd/acr-container-app)
