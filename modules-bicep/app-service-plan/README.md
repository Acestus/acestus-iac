# Acestus App Service Plan Module

Custom Bicep module for App Service Plans using AVM with Acestus defaults.

## Parameters

### Required

| Parameter | Type | Description |
|-----------|------|-------------|
| `name` | string | App Service Plan name |

### Optional

| Parameter | Type | Default | Description |
|-----------|------|---------|-------------|
| `location` | string | `resourceGroup().location` | Azure region |
| `tags` | object | `{}` | Resource tags |
| `skuName` | string | `P0v3` | SKU name |
| `skuCapacity` | int | `1` | SKU capacity |
| `kind` | string | `functionApp` | Plan kind |
| `reserved` | bool | `false` | Linux reserved worker |
| `zoneRedundant` | bool | `false` | Zone redundancy |

## Example

```bicep
module appServicePlan 'br:acracemgtcrprdusw2001.azurecr.io/bicep/modules/app-service-plan:v1.0.0' = {
  name: 'appServicePlan'
  params: {
    name: 'asp-myapp-dev-usw2-001'
    location: location
    tags: tags
    skuName: 'EP1'
    skuCapacity: 1
    kind: 'linux'
  }
}
```

## Outputs

| Output | Type | Description |
|--------|------|-------------|
| `resourceId` | string | App Service Plan resource ID |
| `appServicePlanName` | string | App Service Plan name |
| `appServicePlan` | object | All AVM outputs |

## Version History

- **v1.0.0**: Initial release
