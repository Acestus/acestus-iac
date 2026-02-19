# Monitoring Wrapper Module

## Overview
This module wraps the AVM module `avm/ptn/azd/monitoring` for Acestus deployments. Version: **1.0.0**

## Usage
```bicep
module monitoring 'modules-bicep/avm/ptn/azd/monitoring/main.bicep' = {
  name: 'monitoring'
  params: {
    // Add parameters here
  }
}
```

## Implementation
- Uses AVM module version: `0.2.1`
- Opinionated wrapper for Acestus standards

## Security
- Follows Acestus security best practices

## Documentation
- See [AVM Monitoring](https://github.com/Azure/avm/tree/main/ptn/azd/monitoring)
