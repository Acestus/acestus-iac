# Hub Networking Wrapper Module

## Overview
This module wraps the AVM module `avm/ptn/network/hub-networking` for Acestus deployments. Version: **1.0.0**

## Usage
```bicep
module hubNetworking 'modules-bicep/avm/ptn/network/hub-networking/main.bicep' = {
  name: 'hubNetworking'
  params: {
    // Add parameters here
  }
}
```

## Implementation
- Uses AVM module version: `0.5.0`
- Opinionated wrapper for Acestus standards

## Security
- Follows Acestus security best practices

## Documentation
- See [AVM Hub Networking](https://github.com/Azure/avm/tree/main/ptn/network/hub-networking)
