# CICD Agents and Runners Wrapper Module

## Overview
This module wraps the AVM module `avm/ptn/dev-ops/cicd-agents-and-runners` for Acestus deployments. Version: **1.0.0**

## Usage
```bicep
module cicdAgentsAndRunners 'modules-bicep/avm/ptn/dev-ops/cicd-agents-and-runners/main.bicep' = {
  name: 'cicdAgentsAndRunners'
  params: {
    // Add parameters here
  }
}
```

## Implementation
- Uses AVM module version: `0.3.1`
- Opinionated wrapper for Acestus standards

## Security
- Follows Acestus security best practices

## Documentation
- See [AVM CICD Agents and Runners](https://github.com/Azure/avm/tree/main/ptn/dev-ops/cicd-agents-and-runners)
