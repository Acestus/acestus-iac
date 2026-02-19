# Security Center Wrapper Module

## Overview
This module wraps the AVM module `avm/ptn/security/security-center` for Acestus deployments. Version: **1.0.0**

## Usage
```bicep
module securityCenter 'modules-bicep/avm/ptn/security/security-center/main.bicep' = {
  name: 'securityCenter'
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
- See [AVM Security Center](https://github.com/Azure/avm/tree/main/ptn/security/security-center)
