# Policy Assignment Wrapper Module

## Overview
This module wraps the AVM module `avm/ptn/authorization/policy-assignment` for Acestus deployments. Version: **1.0.0**

## Usage
```bicep
module policyAssignment 'modules-bicep/avm/ptn/authorization/policy-assignment/main.bicep' = {
  name: 'policyAssignment'
  params: {
    // Add parameters here
  }
}
```

## Implementation
- Uses AVM module version: `0.5.3`
- Opinionated wrapper for Acestus standards

## Security
- Follows Acestus security best practices

## Documentation
- See [AVM Policy Assignment](https://github.com/Azure/avm/tree/main/ptn/authorization/policy-assignment)
