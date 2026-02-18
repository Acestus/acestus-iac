# Acestus AI Foundry Module

This is a custom Bicep module for Azure AI Foundry that implements Acestus security standards and naming conventions.

## Features

- **Security First**: HTTPS only, FTPS only, TLS 1.2 minimum
- **Managed Identity Ready**: Defaults to managed identity storage auth
- **Flexible Configuration**: Supports additional app settings and site config
- **Built on AVM**: Uses Azure Verified Modules as the underlying implementation

## Parameters

### Required Parameters

| Parameter | Type | Description |
|-----------|------|-------------|
| `name` | string | AI Foundry resource name |
| `appServicePlanId` | string | App Service Plan resource ID |
| `storageAccountId` | string | Storage account resource ID |
| `storageAccountName` | string | Storage account name for MSI auth |

### Optional Parameters

| Parameter | Type | Default | Description |
|-----------|------|---------|-------------|
| `location` | string | `resourceGroup().location` | Azure region |
| `tags` | object | `{}` | Resource tags |
| `kind` | string | `functionapp` | Resource kind |
| `storageAccountUseIdentityAuthentication` | bool | `true` | Use MSI for storage access |
| `storageAccountConnectionString` | secure string | `''` | Storage connection string (if MSI disabled) |
| `applicationInsightsId` | string | `''` | App Insights resource ID |
| `applicationInsightsConnectionString` | secure string | `''` | App Insights connection string |
| `applicationInsightsInstrumentationKey` | secure string | `''` | App Insights instrumentation key |
| `functionsWorkerRuntime` | string | `powershell` | Worker runtime |
| `functionsWorkerRuntimeVersion` | string | `''` | Runtime version (optional) |
| `functionsExtensionVersion` | string | `~4` | Functions host version |
| `websiteRunFromPackage` | bool | `true` | Enable run from package |
| `alwaysOn` | bool | `false` | Always On setting |
| `httpsOnly` | bool | `true` | Enforce HTTPS only |
| `additionalAppSettings` | array | `[]` | Extra app settings appended |
| `additionalSiteConfig` | object | `{}` | Extra site config merged |
| `enableSystemAssignedIdentity` | bool | `true` | Enable system-assigned identity |
| `userManagedIdentityId` | string | `''` | User-assigned identity resource ID |

## Usage Examples

### Basic AI Foundry Resource
```bicep
module aiFoundry 'br/public:avm/ptn/ai-ml/ai-foundry:0.6.0' = {
  name: 'myAIFoundry'
  params: {
    name: 'ai-foundry-dev-usw2-001'
    location: location
    tags: tags
    appServicePlanId: appServicePlan.id
    storageAccountId: storageAccount.outputs.resourceId
    storageAccountName: storageAccount.outputs.name
    applicationInsightsId: applicationInsights.outputs.resourceId
    applicationInsightsConnectionString: applicationInsights.outputs.connectionString
    functionsWorkerRuntime: 'python'
    functionsExtensionVersion: '~4'
  }
}
```

## Outputs

| Output | Type | Description |
|--------|------|-------------|
| `resourceId` | string | AI Foundry resource ID |
| `resourceName` | string | AI Foundry resource name |
| `defaultHostname` | string | Default hostname |
| `systemAssignedPrincipalId` | string | System-assigned MI principal ID |
| `resource` | object | All AVM module outputs |

## Notes

- If `storageAccountUseIdentityAuthentication` is `false`, provide `storageAccountConnectionString`.
- If you supply `additionalSiteConfig.appSettings`, it overrides the module's default `appSettings` list.

## Version History

- **v1.0.0**: Initial release with Acestus security standards
