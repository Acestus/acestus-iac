# Container Apps Stack Wrapper Module

## Overview
This module wraps the AVM module `avm/ptn/azd/container-apps-stack` for Acestus deployments. Version: **1.0.0**

## Usage
```bicep
module containerAppsStack 'modules-bicep/avm/ptn/azd/container-apps-stack/main.bicep' = {
  name: 'containerAppsStack'
  params: {
    // Add parameters here
  }
}
```

## Implementation
- Uses AVM module version: `0.3.0`
- Opinionated wrapper for Acestus standards

## Security
- Follows Acestus security best practices

## Documentation
- See [AVM Container Apps Stack](https://github.com/Azure/avm/tree/main/ptn/azd/container-apps-stack)
