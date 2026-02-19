# Role Assignment Wrapper Module

## Overview
This module wraps the AVM module `avm/ptn/authorization/role-assignment` for Acestus deployments. Version: **1.0.0**

## Usage
```bicep
module roleAssignment 'modules-bicep/avm/ptn/authorization/role-assignment/main.bicep' = {
  name: 'roleAssignment'
  params: {
    // Add parameters here
  }
}
```

## Implementation
- Uses AVM module version: `0.2.4`
- Opinionated wrapper for Acestus standards

## Security
- Follows Acestus security best practices

## Documentation
- See [AVM Role Assignment](https://github.com/Azure/avm/tree/main/ptn/authorization/role-assignment)
