# Resource Role Assignment Wrapper Module

## Overview
This module wraps the AVM module `avm/ptn/authorization/resource-role-assignment` for Acestus deployments. Version: **1.0.0**

## Usage
```bicep
module resourceRoleAssignment 'modules-bicep/avm/ptn/authorization/resource-role-assignment/main.bicep' = {
  name: 'resourceRoleAssignment'
  params: {
    // Add parameters here
  }
}
```

## Implementation
- Uses AVM module version: `0.1.2`
- Opinionated wrapper for Acestus standards

## Security
- Follows Acestus security best practices

## Documentation
- See [AVM Resource Role Assignment](https://github.com/Azure/avm/tree/main/ptn/authorization/resource-role-assignment)
