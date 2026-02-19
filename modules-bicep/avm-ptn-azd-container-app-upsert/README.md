# Container App Upsert Wrapper Module

## Overview
This module wraps the AVM module `avm/ptn/azd/container-app-upsert` for Acestus deployments. Version: **1.0.0**

## Usage
```bicep
module containerAppUpsert 'modules-bicep/avm/ptn/azd/container-app-upsert/main.bicep' = {
  name: 'containerAppUpsert'
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
- See [AVM Container App Upsert](https://github.com/Azure/avm/tree/main/ptn/azd/container-app-upsert)
