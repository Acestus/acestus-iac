# Remediation Wrapper Module

## Overview
This module wraps the AVM module `avm/ptn/policy-insights/remediation` for Acestus deployments. Version: **1.0.0**

## Usage
```bicep
module remediation 'modules-bicep/avm/ptn/policy-insights/remediation/main.bicep' = {
  name: 'remediation'
  params: {
    // Add parameters here
  }
}
```

## Implementation
- Uses AVM module version: `0.1.0`
- Opinionated wrapper for Acestus standards

## Security
- Follows Acestus security best practices

## Documentation
- See [AVM Remediation](https://github.com/Azure/avm/tree/main/ptn/policy-insights/remediation)
