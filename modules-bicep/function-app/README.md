# Acestus Function App Module

This is a custom Bicep module for Azure Function Apps that implements Acestus security standards and naming conventions.

## Features

- **Security First**: HTTPS only, FTPS only, TLS 1.2 minimum
- **Managed Identity Ready**: Defaults to managed identity storage auth
- **Flexible Configuration**: Supports additional app settings and site config
- **Built on AVM**: Uses Azure Verified Modules as the underlying implementation

## Parameters

### Required Parameters

| Parameter | Type | Description |
|-----------|------|-------------|
| `name` | string | Function App name |
| `appServicePlanId` | string | App Service Plan resource ID |
| `storageAccountId` | string | Storage account resource ID |
| `storageAccountName` | string | Storage account name for MSI auth |

### Optional Parameters

| Parameter | Type | Default | Description |
|-----------|------|---------|-------------|
| `location` | string | `resourceGroup().location` | Azure region |
| `tags` | object | `{}` | Resource tags |
| `kind` | string | `functionapp` | Function App kind |
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

### Basic Function App (PowerShell)
```bicep
module functionApp 'br:acracemgtcrprdusw2001.azurecr.io/bicep/modules/function-app:v1.0.0' = {
  name: 'myFunctionApp'
  params: {
    name: 'func-myapp-dev-usw2-001'
    location: location
    tags: tags
    appServicePlanId: appServicePlan.id
    storageAccountId: storageAccount.outputs.resourceId
    storageAccountName: storageAccount.outputs.name
    applicationInsightsId: applicationInsights.outputs.resourceId
    applicationInsightsConnectionString: applicationInsights.outputs.connectionString
    functionsWorkerRuntime: 'powershell'
    functionsExtensionVersion: '~4'
  }
}
```

### Python Function App with Additional Settings
```bicep
module functionApp 'br:acracemgtcrprdusw2001.azurecr.io/bicep/modules/function-app:v1.0.0' = {
  name: 'myPythonFunctionApp'
  params: {
    name: 'func-myapp-dev-usw2-002'
    location: location
    tags: tags
    appServicePlanId: appServicePlan.id
    storageAccountId: storageAccount.outputs.resourceId
    storageAccountName: storageAccount.outputs.name
    applicationInsightsId: applicationInsights.outputs.resourceId
    applicationInsightsConnectionString: applicationInsights.outputs.connectionString
    functionsWorkerRuntime: 'python'
    functionsWorkerRuntimeVersion: '3.11'
    additionalAppSettings: [
      {
        name: 'MY_CUSTOM_SETTING'
        value: 'true'
      }
    ]
  }
}
```

## Outputs

| Output | Type | Description |
|--------|------|-------------|
| `resourceId` | string | Function App resource ID |
| `functionAppName` | string | Function App name |
| `defaultHostname` | string | Function App default hostname |
| `systemAssignedPrincipalId` | string | System-assigned MI principal ID |
| `functionApp` | object | All AVM module outputs |

## Notes

- If `storageAccountUseIdentityAuthentication` is `false`, provide `storageAccountConnectionString`.
- If you supply `additionalSiteConfig.appSettings`, it overrides the module's default `appSettings` list.

## Version History

- **v1.0.0**: Initial release with Acestus security standards
