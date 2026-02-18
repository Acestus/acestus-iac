# PIM Role Assignment Wrapper Module

## Overview
This module wraps the AVM module `avm/ptn/authorization/pim-role-assignment` for Acestus deployments. Version: **1.0.0**

## Usage
```bicep
module pimRoleAssignment 'modules-bicep/avm/ptn/authorization/pim-role-assignment/main.bicep' = {
  name: 'pimRoleAssignment'
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
- See [AVM PIM Role Assignment](https://github.com/Azure/avm/tree/main/ptn/authorization/pim-role-assignment)
