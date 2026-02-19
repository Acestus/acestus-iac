# FinOps Hub Wrapper Module

## Overview
This module wraps the AVM module `avm/ptn/finops-toolkit/finops-hub` for Acestus deployments. Version: **1.0.0**

## Usage
```bicep
module finopsHub 'modules-bicep/avm/ptn/finops-toolkit/finops-hub/main.bicep' = {
  name: 'finopsHub'
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
- See [AVM FinOps Hub](https://github.com/Azure/avm/tree/main/ptn/finops-toolkit/finops-hub)
