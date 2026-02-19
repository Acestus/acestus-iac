# App Service LZA Hosting Environment Wrapper Module

## Overview
This module wraps the AVM module `avm/ptn/app-service-lza/hosting-environment` for Acestus deployments. Version: **1.0.0**

## Usage
```bicep
module hostingEnvironment 'modules-bicep/avm/ptn/app-service-lza/hosting-environment/main.bicep' = {
  name: 'hostingEnvironment'
  params: {
    // Add parameters here
  }
}
```

## Implementation
- Uses AVM module version: `0.1.1`
- Opinionated wrapper for Acestus standards

## Security
- Follows Acestus security best practices

## Documentation
- See [AVM App Service LZA Hosting Environment](https://github.com/Azure/avm/tree/main/ptn/app-service-lza/hosting-environment)
