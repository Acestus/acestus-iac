# Service Health Alerts Wrapper Module

## Overview
This module wraps the AVM module `avm/ptn/subscription/service-health-alerts` for Acestus deployments. Version: **1.0.0**

## Usage
```bicep
module serviceHealthAlerts 'modules-bicep/avm/ptn/subscription/service-health-alerts/main.bicep' = {
  name: 'serviceHealthAlerts'
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
- See [AVM Service Health Alerts](https://github.com/Azure/avm/tree/main/ptn/subscription/service-health-alerts)
