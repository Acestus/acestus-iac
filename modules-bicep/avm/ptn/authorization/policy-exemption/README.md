# Policy Exemption Wrapper Module

## Overview
This module wraps the AVM module `avm/ptn/authorization/policy-exemption` for Acestus deployments. Version: **1.0.0**

## Usage
```bicep
module policyExemption 'modules-bicep/avm/ptn/authorization/policy-exemption/main.bicep' = {
  name: 'policyExemption'
  params: {
    // Add parameters here
  }
}
```

## Implementation
- Uses AVM module version: `0.2.0`
- Opinionated wrapper for Acestus standards

## Security
- Follows Acestus security best practices

## Documentation
- See [AVM Policy Exemption](https://github.com/Azure/avm/tree/main/ptn/authorization/policy-exemption)
