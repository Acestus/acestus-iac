# Acestus Application Insights Module

Custom Bicep module for Application Insights using AVM with Acestus defaults.

## Parameters

### Required

| Parameter | Type | Description |
|-----------|------|-------------|
| `name` | string | Application Insights name |
| `workspaceResourceId` | string | Log Analytics workspace resource ID |

### Optional

| Parameter | Type | Default | Description |
|-----------|------|---------|-------------|
| `location` | string | `resourceGroup().location` | Azure region |
| `tags` | object | `{}` | Resource tags |
| `applicationType` | string | `web` | Application type |
| `kind` | string | `web` | Resource kind |
| `disableIpMasking` | bool | `true` | Disable IP masking |
| `disableLocalAuth` | bool | `false` | Disable local auth |
| `publicNetworkAccessForIngestion` | string | `Enabled` | Public network access for ingestion |
| `publicNetworkAccessForQuery` | string | `Enabled` | Public network access for query |
| `retentionInDays` | int | `365` | Retention period |

## Example

```bicep
module appInsights 'br:acracemgtcrprdusw2001.azurecr.io/bicep/modules/app-insights:v1.0.0' = {
  name: 'appInsights'
  params: {
    name: 'ai-myapp-dev-usw2-001'
    location: location
    tags: tags
    workspaceResourceId: logAnalytics.outputs.resourceId
  }
}
```

## Outputs

| Output | Type | Description |
|--------|------|-------------|
| `resourceId` | string | Application Insights resource ID |
| `applicationInsightsName` | string | Application Insights name |
| `instrumentationKey` | string | Instrumentation key |
| `connectionString` | string | Connection string |
| `applicationInsights` | object | All AVM outputs |

## Version History

- **v1.0.0**: Initial release
