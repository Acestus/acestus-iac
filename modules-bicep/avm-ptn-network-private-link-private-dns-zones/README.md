# Private Link Private DNS Zones Wrapper Module

## Overview
This module wraps the AVM module `avm/ptn/network/private-link-private-dns-zones` for Acestus deployments. Version: **1.0.0**

## Usage
```bicep
module privateLinkPrivateDnsZones 'modules-bicep/avm/ptn/network/private-link-private-dns-zones/main.bicep' = {
  name: 'privateLinkPrivateDnsZones'
  params: {
    // Add parameters here
  }
}
```

## Implementation
- Uses AVM module version: `0.7.2`
- Opinionated wrapper for Acestus standards

## Security
- Follows Acestus security best practices

## Documentation
- See [AVM Private Link Private DNS Zones](https://github.com/Azure/avm/tree/main/ptn/network/private-link-private-dns-zones)
