# Subscription Placement Wrapper Module

## Overview
This module wraps the AVM module `avm/ptn/mgmt-groups/subscription-placement` for Acestus deployments. Version: **1.0.0**

## Usage
```bicep
module subscriptionPlacement 'modules-bicep/avm/ptn/mgmt-groups/subscription-placement/main.bicep' = {
  name: 'subscriptionPlacement'
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
- See [AVM Subscription Placement](https://github.com/Azure/avm/tree/main/ptn/mgmt-groups/subscription-placement)
