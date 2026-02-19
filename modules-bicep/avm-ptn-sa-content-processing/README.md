# Content Processing Wrapper Module

## Overview
This module wraps the AVM module `avm/ptn/sa/content-processing` for Acestus deployments. Version: **1.0.0**

## Usage
```bicep
module contentProcessing 'modules-bicep/avm/ptn/sa/content-processing/main.bicep' = {
  name: 'contentProcessing'
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
- See [AVM Content Processing](https://github.com/Azure/avm/tree/main/ptn/sa/content-processing)
