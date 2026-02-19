# Insights Dashboard Wrapper Module

## Overview
This module wraps the AVM module `avm/ptn/azd/insights-dashboard` for Acestus deployments. Version: **1.0.0**

## Usage
```bicep
module insightsDashboard 'modules-bicep/avm/ptn/azd/insights-dashboard/main.bicep' = {
  name: 'insightsDashboard'
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
- See [AVM Insights Dashboard](https://github.com/Azure/avm/tree/main/ptn/azd/insights-dashboard)
