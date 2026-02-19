# Role Definition Wrapper Module

## Overview
This module wraps the AVM module `avm/ptn/authorization/role-definition` for Acestus deployments. Version: **1.0.0**

## Usage
```bicep
module roleDefinition 'modules-bicep/avm/ptn/authorization/role-definition/main.bicep' = {
  name: 'roleDefinition'
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
- See [AVM Role Definition](https://github.com/Azure/avm/tree/main/ptn/authorization/role-definition)
